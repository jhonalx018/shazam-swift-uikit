//
//  URLRequest+Extensions.swift
//  Shazam
//
//  Created by Jhon Gomez on 8/3/22.
//

import Foundation

enum HTTPMethods: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

extension URLRequest {
    init(url: URL, method: HTTPMethods) {
        self.init(url: url)
        self.httpMethod = method.rawValue
    }
}
