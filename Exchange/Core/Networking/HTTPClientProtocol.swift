//
//  HTTPClientProtocol.swift
//  Exchange
//

import Foundation

// MARK: - HTTPClientError

enum HTTPClientError: Error, Equatable {
    case invalidResponse
    case statusCode(Int)
    case transport(String)
}

// MARK: - HTTPClientProtocol

protocol HTTPClientProtocol {
    func get(url: URL) async throws -> Data
}
