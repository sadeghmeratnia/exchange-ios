//
//  DefaultRetryPolicy.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

struct DefaultRetryPolicy: RetryPolicy {
    let maxRetries: Int

    init(maxRetries: Int = 3) {
        precondition(maxRetries >= 1, "maxRetries must be at least 1")
        self.maxRetries = maxRetries
    }

    func shouldRetry(context: RetryContext) -> Bool {
        guard context.attempt < maxRetries else { return false }

        switch context.failure {
        case let .httpStatus(code):
            guard context.isIdempotentRequest else { return false }
            return [408, 425, 429, 500, 502, 503, 504].contains(code)
        case let .transport(code):
            return [.timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost].contains(code)
        case .other:
            return false
        }
    }

    func delay(for context: RetryContext) -> UInt64 {
        let base = pow(2.0, Double(context.attempt))
        let jitter = Double.random(in: 0 ... 1.0)
        return UInt64((base + jitter) * 1_000_000_000)
    }
}
