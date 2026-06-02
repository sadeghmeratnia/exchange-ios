//
//  ExchangeEndpoints.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeEndpoints

enum ExchangeEndpoints {
    static let baseURL: URL = {
        guard let url = URL(string: "https://api.dolarapp.dev/v1/") else {
            fatalError("ExchangeEndpoints: invalid base URL literal")
        }
        return url
    }()

    static func tickers(currencies: [String]) -> Endpoint {
        Endpoint(
            baseURL: baseURL,
            path: "tickers",
            queryItems: [
                URLQueryItem(
                    name: "currencies",
                    value: currencies.joined(separator: ",")),
            ])
    }

    static func tickerCurrencies() -> Endpoint {
        Endpoint(
            baseURL: baseURL,
            path: "tickers-currencies")
    }
}
