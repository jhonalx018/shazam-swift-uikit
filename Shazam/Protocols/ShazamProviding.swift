//
//  ShazamProviding.swift
//  Shazam
//
//  Created by Jhon Gomez on 7/25/22.
//

import Foundation
import Combine

public enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
}

public typealias Response<R> = Result<R, NetworkError>
public typealias AnyPublisherRequest<R> = AnyPublisher<Response<R>, Never>

protocol ShazamProviding {
    func searchData(term: String) -> AnyPublisherRequest<ShazamResponse>
}

extension ShazamProviding {
    func searchData(term: String) -> AnyPublisherRequest<ShazamResponse> {
        // Api headers
        // Get api key https://rapidapi.com/apidojo/api/shazam

        let headers = [
            "X-RapidAPI-Key": "",
            "X-RapidAPI-Host": ""
        ]

        headers.values.forEach {
            if $0.isEmpty {
                fatalError("Shazam ApiKeys are required")
            }
        }

        var components = URLComponents(string: "https://shazam.p.rapidapi.com/search")!
        components.queryItems = [
            URLQueryItem(name: "term", value: term)
        ]

        var request = URLRequest(url: components.url!)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { response -> Response<ShazamResponse> in
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(ShazamResponse.self, from: response.data)

                    return .success(data)
                } catch let error {
                    return .failure(.encodingError(error))
                }
            }
            .replaceError(with: .failure(.noData))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class ShazamProvider: ShazamProviding {
    /// Term to look up on Shazam
    var term = PassthroughSubject<String, Never>()

    /// Api state
    var isLoading = CurrentValueSubject<Bool, Never>(false)

    /// Used  to hold Shazam data
    var data = CurrentValueSubject<ShazamResponse, Never>(ShazamResponse(tracks: nil))

    var recents = [String]() {
        didSet {
            if oldValue.count > 2 {
                recents.removeFirst()
            }
        }
    }

    /// Subscriptions
    private var subscriptions: Set<AnyCancellable> = []

    init() {
        commonInit()
    }

    /// Create subscriptions to get the data from Shazam
    private func commonInit() {
        term
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            // filter
            .filter { self.recents.last != $0 && !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            // Side effect to update to check if the API is performing a request
            .map { term -> String in
                self.isLoading.send(true)
                return term
            }
            // In case the term is empty we can clean up the information
            .flatMap(maxPublishers: .max(1), { term ->  AnyPublisherRequest<ShazamResponse> in
                self.recents.append(term)

                return term.isEmpty ? Just(Result.success(ShazamResponse(tracks: nil))).eraseToAnyPublisher() : self.searchData(term: term)
            })
            .sink(receiveValue: { value in
                self.isLoading.send(false)
                
                switch value {
                    case .success(let data):
                        self.data.send(data)
                    case .failure(let error):
                        print(error)
                }
            }).store(in: &subscriptions)
    }

    deinit {
        // remove subscriptions
        subscriptions.removeAll()
    }
}
