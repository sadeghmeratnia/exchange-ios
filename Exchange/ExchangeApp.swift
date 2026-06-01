//
//  ExchangeApp.swift
//  Exchange
//
//  Created by Sadegh on 30/05/2026.
//

import Foundation
import SwiftUI

@main
struct ExchangeApp: App {
    private let appContainer: AppContainer

    init() {
        let logger = OSNetworkLogger()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let networkClient = URLSessionNetworkClient(
            session: URLSession.shared,
            decoder: decoder,
            retryPolicy: DefaultRetryPolicy(),
            logger: logger)

        self.appContainer = AppContainer(
            networkClient: networkClient,
            logger: logger)
    }

    var body: some Scene {
        WindowGroup {
            ExchangeFeatureBuilder(appContainer: appContainer).makeRootView()
        }
    }
}
