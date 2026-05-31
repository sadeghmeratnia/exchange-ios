//
//  EndpointTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

import Testing
@testable import Exchange
import Foundation

// MARK: - EndpointTests

@Suite("Endpoint")
struct EndpointTests {
    // MARK: - URL Construction

    @Suite("URL Construction")
    struct URLConstruction {
        @Test("Builds correct URL from base and path")
        func buildsCorrectURL() throws {
            let request = try makeRequest(
                path: "tickers",
                baseURL: EndpointTests.exchangeBaseURL)
            #expect(request.url?.absoluteString == "https://api.dolarapp.dev/v1/tickers")
        }

        @Test("Strips leading slash from path")
        func stripsLeadingSlash() throws {
            let request = try makeRequest(
                path: "/tickers",
                baseURL: EndpointTests.exchangeBaseURL)
            #expect(request.url?.absoluteString == "https://api.dolarapp.dev/v1/tickers")
        }

        @Test("Path without leading slash and path with leading slash produce same URL")
        func leadingSlashIsNormalized() throws {
            let withSlash = try makeRequest(
                path: "/tickers",
                baseURL: EndpointTests.exchangeBaseURL)
            let withoutSlash = try makeRequest(
                path: "tickers",
                baseURL: EndpointTests.exchangeBaseURL)

            #expect(withSlash.url == withoutSlash.url)
        }
    }

    // MARK: - HTTP Method

    @Suite("HTTP Method")
    struct HTTPMethodTests {
        @Test("Defaults to GET", arguments: [
            ("tickers", "GET"),
            ("tickers-currencies", "GET"),
        ])
        func defaultsToGET(path: String, expectedMethod: String) throws {
            let request = try makeRequest(path: path)

            #expect(request.httpMethod == expectedMethod)
        }

        @Test("Sets correct HTTP method", arguments: [
            HTTPMethod.get,
            HTTPMethod.post,
            HTTPMethod.put,
        ])
        func setsHTTPMethod(method: HTTPMethod) throws {
            let request = try makeRequest(path: "tickers", method: method)

            #expect(request.httpMethod == method.rawValue)
        }
    }

    // MARK: - Query Items

    @Suite("Query Items")
    struct QueryItemTests {
        @Test("Appends query items to URL")
        func appendsQueryItems() throws {
            let request = try makeRequest(
                path: "tickers",
                queryItems: [URLQueryItem(name: "currencies", value: "MXN,ARS")])
            let components = try URLComponents(url: #require(request.url), resolvingAgainstBaseURL: false)

            #expect(components?.queryItems?.contains(URLQueryItem(name: "currencies", value: "MXN,ARS")) == true)
        }

        @Test("Appends multiple query items")
        func appendsMultipleQueryItems() throws {
            let request = try makeRequest(
                path: "tickers",
                queryItems: [
                    URLQueryItem(name: "currencies", value: "MXN,ARS"),
                    URLQueryItem(name: "include_inactive", value: "false"),
                ])
            let components = try URLComponents(url: #require(request.url), resolvingAgainstBaseURL: false)

            #expect(components?.queryItems?.count == 2)
        }

        @Test("Empty query items produces no query string")
        func emptyQueryItems() throws {
            let request = try makeRequest(path: "tickers", queryItems: [])

            #expect(request.url?.query == nil)
        }
    }

    // MARK: - Headers

    @Suite("Headers")
    struct HeaderTests {
        @Test("Sets custom headers on request")
        func setsHeaders() throws {
            let request = try makeRequest(
                path: "tickers",
                headers: ["Authorization": "Bearer token123"])

            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
        }

        @Test("Sets multiple headers")
        func setsMultipleHeaders() throws {
            let request = try makeRequest(
                path: "tickers",
                headers: [
                    "Authorization": "Bearer token123",
                    "Accept": "application/json",
                ])

            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
            #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        }

        @Test("No headers produces empty header fields")
        func noHeaders() throws {
            let request = try makeRequest(path: "tickers")

            #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
        }
    }

    // MARK: - Timeout

    @Suite("Timeout")
    struct TimeoutTests {
        @Test("Defaults to 30 seconds")
        func defaultTimeout() throws {
            let request = try makeRequest(path: "tickers")

            #expect(request.timeoutInterval == 30)
        }

        @Test("Sets custom timeout interval")
        func customTimeout() throws {
            let request = try makeRequest(path: "tickers", timeoutInterval: 60)

            #expect(request.timeoutInterval == 60)
        }
    }

}

extension EndpointTests {
    fileprivate static let exchangeBaseURL = URL(string: "https://api.dolarapp.dev/v1/")!

    fileprivate static func makeRequest(path: String,
                                        method: HTTPMethod = .get,
                                        queryItems: [URLQueryItem] = [],
                                        headers: [String: String] = [:],
                                        timeoutInterval: TimeInterval = 30,
                                        baseURL: URL = exchangeBaseURL) throws -> URLRequest {
        try Endpoint(
            baseURL: baseURL,
            path: path,
            method: method,
            queryItems: queryItems,
            headers: headers,
            timeoutInterval: timeoutInterval)
            .urlRequest()
    }
}
