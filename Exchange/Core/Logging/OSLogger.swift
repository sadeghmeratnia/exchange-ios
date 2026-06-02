//
//  OSLogger.swift
//  Exchange
//
//  Created by Sadegh on 02/06/2026.
//

import OSLog

// MARK: - LogCategory

enum LogCategory: String {
    case network = "Network"
    case cache = "Cache"
}

// MARK: - OSLogger

struct OSLogger: NetworkLogger {
    private let logger: Logger

    init(category: LogCategory) {
        logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "app",
            category: category.rawValue)
    }

    func log(_ message: String, level: LogLevel) {
        switch level {
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        }
    }
}
