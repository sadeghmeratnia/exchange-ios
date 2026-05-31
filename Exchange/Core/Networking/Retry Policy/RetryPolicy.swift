//
//  RetryPolicy.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

struct RetryContext {
    enum Failure {
        case httpStatus(Int)
        case transport(URLError.Code)
        case other
    }

    let attempt: Int
    let method: String?
    let failure: Failure

    var isIdempotentRequest: Bool {
        guard let method else { return false }
        return ["GET", "HEAD", "PUT", "DELETE", "OPTIONS"].contains(method.uppercased())
    }
}

protocol RetryPolicy {
    func shouldRetry(context: RetryContext) -> Bool
    func delay(for context: RetryContext) -> UInt64
}
