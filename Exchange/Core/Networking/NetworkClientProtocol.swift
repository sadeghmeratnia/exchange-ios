//
//  NetworkClientProtocol.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

protocol NetworkClientProtocol {
    func requestData(endpoint: Endpoint) async throws -> Data
    func request<T: Decodable>(_ type: T.Type, endpoint: Endpoint) async throws -> T
}
