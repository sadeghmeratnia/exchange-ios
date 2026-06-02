//
//  MockLogger.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

@testable import Exchange
import Foundation

struct MockLogger: NetworkLogger {
    struct Entry: Equatable {
        let message: String
        let level: LogLevel
    }

    private let onLog: ((String, LogLevel) -> Void)?

    init(onLog: ((String, LogLevel) -> Void)? = nil) {
        self.onLog = onLog
    }

    func log(_ message: String, level: LogLevel) {
        onLog?(message, level)
    }

    static func recording(_ store: RecordingLogStore) -> MockLogger {
        MockLogger { message, level in
            store.append(message: message, level: level)
        }
    }
}

final class RecordingLogStore: @unchecked Sendable {
    private(set) var entries: [MockLogger.Entry] = []

    func append(message: String, level: LogLevel) {
        entries.append(MockLogger.Entry(message: message, level: level))
    }
}
