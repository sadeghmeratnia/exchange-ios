//
//  AppContainer.swift
//  Exchange
//
//  Created by Sadegh on 30/05/2026.
//

import Foundation

final class AppContainer {
    let networkClient: NetworkClientProtocol
    let logger: NetworkLogger

    init(networkClient: NetworkClientProtocol,
         logger: NetworkLogger) {
        self.networkClient = networkClient
        self.logger = logger
    }

    static func live() -> AppContainer {
        let logger = OSLogger(category: .network)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let networkClient = URLSessionNetworkClient(
            session: URLSession.shared,
            decoder: decoder,
            retryPolicy: DefaultRetryPolicy(),
            logger: logger)

        return AppContainer(
            networkClient: networkClient,
            logger: logger)
    }
}
