//
//  URLSessionHTTPClient.swift
//  Exchange
//

import Foundation

final class URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPClientError.invalidResponse
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                throw HTTPClientError.statusCode(httpResponse.statusCode)
            }

            return data
        } catch let error as HTTPClientError {
            throw error
        } catch {
            throw HTTPClientError.transport(error.localizedDescription)
        }
    }
}
