//
//  APIRequestBuilder.swift
//  Exchange
//

import Foundation

enum APIRequestBuilder {
    private static let scheme = "https"
    private static let host = "api.dolarapp.dev"
    private static let versionPath = "/v1"

    static func tickers(currencies: [String]) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "\(versionPath)/tickers"
        components.queryItems = [
            URLQueryItem(name: "currencies", value: currencies.joined(separator: ","))
        ]
        return components.url
    }

    static func tickerCurrencies() -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "\(versionPath)/tickers-currencies"
        return components.url
    }
}
