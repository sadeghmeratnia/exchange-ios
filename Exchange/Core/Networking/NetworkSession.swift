//
//  NetworkSession.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - NetworkSession

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession + NetworkSession

extension URLSession: NetworkSession { }
