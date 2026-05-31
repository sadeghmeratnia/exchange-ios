//
//  URLSessionNetworkClient.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - URLSessionNetworkClient

final class URLSessionNetworkClient: NetworkClientProtocol {
    private let session: NetworkSession
    private let makeDecoder: @Sendable () -> JSONDecoder
    private let retryPolicy: RetryPolicy
    private let logger: NetworkLogger

    init(session: NetworkSession,
         decoder: JSONDecoder,
         retryPolicy: RetryPolicy,
         logger: NetworkLogger) {
        self.session = session
        self.makeDecoder = {
            let configuredDecoder = JSONDecoder()
            configuredDecoder.keyDecodingStrategy = decoder.keyDecodingStrategy
            configuredDecoder.dateDecodingStrategy = decoder.dateDecodingStrategy
            configuredDecoder.dataDecodingStrategy = decoder.dataDecodingStrategy
            configuredDecoder.nonConformingFloatDecodingStrategy = decoder.nonConformingFloatDecodingStrategy
            configuredDecoder.userInfo = decoder.userInfo
            return configuredDecoder
        }
        self.retryPolicy = retryPolicy
        self.logger = logger
    }

    func requestData(endpoint: Endpoint) async throws -> Data {
        let request = try endpoint.urlRequest()
        logger.log("→ \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")", level: .info)

        let data = try await execute(request: request)
        return data
    }

    func request<T: Decodable & Sendable>(_ type: T.Type, endpoint: Endpoint) async throws -> T {
        let data = try await requestData(endpoint: endpoint)
        do {
            return try makeDecoder().decode(type, from: data)
        } catch {
            logger.log("✖ Decoding failed for \(T.self): \(error)", level: .error)
            throw NetworkError.decoding(error)
        }
    }

    private func execute(request: URLRequest, attempt: Int = 0) async throws -> Data {
        try Task.checkCancellation()
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                let context = RetryContext(
                    attempt: attempt,
                    method: request.httpMethod,
                    failure: .httpStatus(httpResponse.statusCode))
                return try await retryOrThrow(
                    NetworkError.statusCode(httpResponse.statusCode),
                    context: context,
                    request: request,
                    attempt: attempt)
            }

            logger.log("← \(httpResponse.statusCode)", level: .info)
            return data

        } catch is CancellationError {
            logger.log("ℹ️ Request cancelled", level: .info)
            throw CancellationError()

        } catch let urlError as URLError {
            let context = RetryContext(
                attempt: attempt,
                method: request.httpMethod,
                failure: .transport(urlError.code))
            return try await retryOrThrow(
                NetworkError.transport(urlError),
                context: context,
                request: request,
                attempt: attempt)

        } catch let networkError as NetworkError {
            throw networkError

        } catch {
            logger.log("✖ Unknown error: \(error)", level: .error)
            throw NetworkError.unknown(underlying: error)
        }
    }

    private func retryOrThrow(_ error: NetworkError,
                              context: RetryContext,
                              request: URLRequest,
                              attempt: Int) async throws -> Data {
        if retryPolicy.shouldRetry(context: context) {
            logger.log("⚠️ Retrying attempt \(attempt + 1): \(error)", level: .warning)
            try await Task.sleep(nanoseconds: retryPolicy.delay(for: context))
            return try await execute(request: request, attempt: attempt + 1)
        }
        logger.log("✖ Non-retryable: \(error)", level: .error)
        throw error
    }
}
