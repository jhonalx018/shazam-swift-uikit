//
//  URLSessions+Extensions.swift
//  Shazam
//
//  Created by Jhon Gomez on 8/2/22.
//

import Foundation
import UIKit


extension URLSession {

    /// Perform a request to Shazam API `https://rapidapi.com/apidojo/api/shazam`
    /// - Parameter request: Input  data `URLRequest` where shazam headers will be added
    /// - Returns: `DataTaskPublisher` with the result
    static func shazamRequest(for request: inout URLRequest) -> DataTaskPublisher {
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

        request.allHTTPHeaderFields = headers
        return URLSession.shared.dataTaskPublisher(for: request)
    }
}
