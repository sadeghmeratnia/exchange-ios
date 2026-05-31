//
//  RetryPolicy.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

protocol RetryPolicy {
    func shouldRetry(error: Error, attempt: Int) -> Bool
    func delay(for attempt: Int) -> UInt64
}
