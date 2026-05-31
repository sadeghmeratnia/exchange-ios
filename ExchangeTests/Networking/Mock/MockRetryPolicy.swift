//
//  MockRetryPolicy.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

@testable import Exchange
import Foundation

struct MockRetryPolicy: RetryPolicy {
    var shouldRetryHandler: (RetryContext) -> Bool = { _ in false }
    var delayHandler: (RetryContext) -> UInt64 = { _ in 0 }

    func shouldRetry(context: RetryContext) -> Bool {
        shouldRetryHandler(context)
    }

    func delay(for context: RetryContext) -> UInt64 {
        delayHandler(context)
    }
}
