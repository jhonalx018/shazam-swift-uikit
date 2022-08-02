//
//  URLRequest+Extensions.swift
//  Shazam
//
//  Created by Jhon Gomez on 8/2/22.
//

import Foundation
import Combine

extension URLComponents {
    init(url: String, params: Array<(String, String)>) {
        self.init(string: url)!

        self.queryItems = params.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
    }
}
