//
//  MockLogger.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

@testable import Exchange
import Foundation

struct MockLogger: NetworkLogger {
    func log(_: String, level _: LogLevel) { }
}
