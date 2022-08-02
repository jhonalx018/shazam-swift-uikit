//
//  ApiCallType.swift
//  Shazam
//
//  Created by Jhon Gomez on 8/2/22.
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
