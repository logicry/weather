//
//  WebProvider.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import Foundation

enum WebProviderError: Error {
    case responseFailure
}

protocol WebProviderContract {
    func get(from url: URL) async throws -> (Data, URLResponse)
}

class WebProvider {
    static let weatherApiKey = "ae0566b968e132f21115f747a5fc770d"
    static let shared = WebProvider()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()
}

extension WebProvider: WebProviderContract {
    func get(from url: URL) async throws -> (Data, URLResponse) {
        return try await session.data(from: url)
    }
}
