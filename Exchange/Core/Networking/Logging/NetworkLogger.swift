//
//  NetworkLogger.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

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
