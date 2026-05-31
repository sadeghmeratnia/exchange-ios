//
//  Helpers.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

@testable import Exchange
import Foundation

extension HTTPURLResponse {
    static func make(url: URL = URL(string: "https://example.com")!,
                     statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
    }
}

extension Endpoint {
    static var mock: Endpoint {
        Endpoint(baseURL: URL(string: "https://example.com")!, path: "mock")
    }
}
