//
//  ShazamProviding.swift
//  Shazam
//
//  Created by Jhon Gomez on 7/25/22.
//

import Foundation
import Combine


protocol ShazamProviding {
    func searchData(with term: String) -> AnyPublisherRequest<ShazamResponse>

    var term: PassthroughSubject<String, Never> { get set }
    var isLoading: CurrentValueSubject<Bool, Never> { get set }
    var recents: [String] { get set }
    var data: CurrentValueSubject<ShazamResponse, Never> { get set }
}

extension ShazamProviding {
    /// Perform a request to lookup on `Shazam` a specific term,  HTTP `GET`
    /// - Parameter term: term to look up`String`
    /// - Returns: `AnyPublisherRequest<ShazamResponse>`
    func searchData(with term: String) -> AnyPublisherRequest<ShazamResponse> {
        let components = URLComponents(url: "https://shazam.p.rapidapi.com/search", params: [
            ("term", term)
        ])
        var request = URLRequest(url: components.url!, method: .GET)

        return URLSession.shazamApiPerformCall(with: &request)
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

/// `ShazamProvider`
class ShazamProvider: ShazamProviding {
    /// Term to look up on Shazam
    var term = PassthroughSubject<String, Never>()

    /// Api request state
    var isLoading = CurrentValueSubject<Bool, Never>(false)

    /// Used  to hold Shazam data
    var data = CurrentValueSubject<ShazamResponse, Never>(ShazamResponse(tracks: nil))

    /// Recents terms requested
    var recents = [String]() {
        didSet {
            if oldValue.count > 2 {
                recents.removeLast()
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
            // Filter whether the term is empty or is the same value as the last term searched
            .filter { self.recents.first != $0 && !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            // Side effect to update to check if the API is performing a request
            .handleEvents(receiveOutput: { term in
                self.isLoading.send(true)
                self.recents.insert(term, at: 0)
            })
            // In case the term is empty we can clean up the information
            .flatMap(maxPublishers: .max(1), self.searchData)
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
        // Remove subscriptions
        subscriptions.removeAll()
    }
}
