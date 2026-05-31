//
//  MockNetworkSession.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation
@testable import Exchange

final class MockNetworkSession: NetworkSession {
    typealias Handler = (URLRequest) throws -> (Data, URLResponse)

    private let handler: Handler

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try handler(request)
    }
}
