//
//  NetworkLogger.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation
import os

protocol NetworkObserving {
    func requestStarted(endpointName: String, request: URLRequest)
    func requestFinished(
        endpointName: String,
        request: URLRequest,
        response: HTTPURLResponse?,
        error: Error?,
        duration: TimeInterval,
        attempt: Int
    )
}

struct NetworkLoggerObserver: NetworkObserving {
    private let logger = Logger(subsystem: "com.sadegh.exchange", category: "network")

    func requestStarted(endpointName: String, request: URLRequest) {
        #if DEBUG
        logger.debug("➡️ [\(endpointName)] \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "nil")")
        #endif
    }

    func requestFinished(
        endpointName: String,
        request _: URLRequest,
        response: HTTPURLResponse?,
        error: Error?,
        duration: TimeInterval,
        attempt: Int
    ) {
        #if DEBUG
        let durationString = String(format: "%.3f", duration)
        if let response {
            logger.debug("✅ [\(endpointName)] status=\(response.statusCode) attempt=\(attempt) duration=\(durationString)s")
        } else if let error {
            logger.error("❌ [\(endpointName)] attempt=\(attempt) duration=\(durationString)s error=\(error.localizedDescription)")
        } else {
            logger.error("❌ [\(endpointName)] attempt=\(attempt) duration=\(durationString)s unknown result")
        }
        #endif
    }
}

// MARK: - NetworkLogger

protocol NetworkLogger {
    func log(_ message: String, level: LogLevel)
}

// MARK: - LogLevel

enum LogLevel {
    case debug
    case info
    case warning
    case error
}
