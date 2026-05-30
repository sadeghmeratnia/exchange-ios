//
//  AppContainer.swift
//  Exchange
//

import Foundation

final class AppContainer {
    let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
}
