//
//  AppContainer.swift
//  Exchange
//
//  Created by Sadegh on 30/05/2026.
//

import Foundation

final class AppContainer {
    let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
}
