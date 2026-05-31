//
//  DefaultRetryPolicyTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

import Testing
@testable import Exchange
import Foundation

// MARK: - DefaultRetryPolicyTests

@Suite("DefaultRetryPolicy")
enum DefaultRetryPolicyTests {
    // MARK: - Initialization

    @Suite("Initialization")
    struct Initialization {
        @Test("Accepts minimum valid maxAttempts of 1")
        func acceptsMinimumValidMaxAttempts() {
            #expect(throws: Never.self) {
                _ = makePolicy(maxRetries: 1)
            }
        }

        @Test("Accepts valid maxAttempts", arguments: [1, 2, 3, 10])
        func acceptsValidMaxAttempts(maxAttempts: Int) {
            #expect(throws: Never.self) {
                _ = makePolicy(maxRetries: maxAttempts)
            }
        }

        @Test("Default maxAttempts is 3")
        func defaultMaxAttempts() {
            let policy = makePolicy()
            #expect(policy.maxRetries == 3)
        }
    }

    // MARK: - Status Code Retries

    @Suite("Status Code Retries")
    struct StatusCodeRetries {
        @Test("Retries on 429 for idempotent method", arguments: [0, 1, 2])
        func retriesOn429(attempt: Int) {
            assertShouldRetry(
                true,
                context: .init(attempt: attempt, method: "GET", failure: .httpStatus(429))
            )
        }

        @Test("Retries on 503 for idempotent method", arguments: [0, 1, 2])
        func retriesOn503(attempt: Int) {
            assertShouldRetry(
                true,
                context: .init(attempt: attempt, method: "GET", failure: .httpStatus(503))
            )
        }

        @Test("Does not retry on non-retryable status codes", arguments: [
            400, 401, 403, 404
        ])
        func doesNotRetryOnNonRetryableStatusCodes(statusCode: Int) {
            assertShouldRetry(
                false,
                context: .init(attempt: 0, method: "GET", failure: .httpStatus(statusCode))
            )
        }

        @Test("Does not retry for non-idempotent method even for retryable status", arguments: [
            "POST", "PATCH"
        ])
        func doesNotRetryForNonIdempotentMethod(method: String) {
            assertShouldRetry(
                false,
                context: .init(attempt: 0, method: method, failure: .httpStatus(503))
            )
        }

        @Test("Does not retry when attempts exhausted on retryable status")
        func doesNotRetryWhenAttemptsExhausted() {
            assertShouldRetry(
                false,
                context: .init(attempt: 3, method: "GET", failure: .httpStatus(503))
            )
        }
    }

    // MARK: - URLError Retries

    @Suite("URLError Retries")
    struct URLErrorRetries {
        @Test("Retries on timed out error", arguments: [0, 1, 2])
        func retriesOnTimedOut(attempt: Int) {
            assertShouldRetry(
                true,
                context: .init(attempt: attempt, method: "GET", failure: .transport(.timedOut))
            )
        }

        @Test("Retries on network connection lost", arguments: [0, 1, 2])
        func retriesOnNetworkConnectionLost(attempt: Int) {
            assertShouldRetry(
                true,
                context: .init(attempt: attempt, method: "GET", failure: .transport(.networkConnectionLost))
            )
        }

        @Test("Does not retry on non-retryable URLErrors", arguments: [
            URLError.Code.cancelled,
            URLError.Code.badURL,
            URLError.Code.unsupportedURL,
            URLError.Code.userAuthenticationRequired
        ])
        func doesNotRetryOnNonRetryableURLErrors(code: URLError.Code) {
            DefaultRetryPolicyTests.assertShouldRetry(
                false,
                context: .init(attempt: 0, method: "GET", failure: .transport(code))
            )
        }

        @Test("Does not retry transport error when attempts exhausted")
        func doesNotRetryTransportWhenAttemptsExhausted() {
            assertShouldRetry(
                false,
                context: .init(attempt: 3, method: "GET", failure: .transport(.timedOut))
            )
        }
    }

    // MARK: - Non-Retryable Error Types

    @Suite("Non-Retryable Error Types")
    struct NonRetryableErrorTypes {
        @Test("Does not retry on .other failures")
        func doesNotRetryOnOtherFailures() {
            assertShouldRetry(
                false,
                context: .init(attempt: 0, method: "GET", failure: .other)
            )
        }
    }

    // MARK: - Delay

    @Suite("Delay")
    struct DelayTests {
        @Test("Delay increases with attempt number")
        func delayIncreasesWithAttempt() {
            let policy = DefaultRetryPolicyTests.makePolicy()
            let delay0 = policy.delay(for: .init(attempt: 0, method: "GET", failure: .other))
            let delay1 = policy.delay(for: .init(attempt: 1, method: "GET", failure: .other))
            let delay2 = policy.delay(for: .init(attempt: 2, method: "GET", failure: .other))

            #expect(delay1 > delay0)
            #expect(delay2 > delay1)
        }

        @Test("Delay is within expected range for attempt 0")
        func delayRangeForAttempt0() {
            let policy = DefaultRetryPolicyTests.makePolicy()
            let delay = policy.delay(for: .init(attempt: 0, method: "GET", failure: .other))

            // base = 1.0, jitter = 0...1.0, range is 1.0...2.0 seconds
            let minDelay = UInt64(1.0 * 1_000_000_000)
            let maxDelay = UInt64(2.0 * 1_000_000_000)
            #expect(delay >= minDelay)
            #expect(delay <= maxDelay)
        }

        @Test("Delay is within expected range for attempt 1")
        func delayRangeForAttempt1() {
            let policy = DefaultRetryPolicyTests.makePolicy()
            let delay = policy.delay(for: .init(attempt: 1, method: "GET", failure: .other))

            // base = 2.0, jitter = 0...1.0, range is 2.0...3.0 seconds
            let minDelay = UInt64(2.0 * 1_000_000_000)
            let maxDelay = UInt64(3.0 * 1_000_000_000)
            #expect(delay >= minDelay)
            #expect(delay <= maxDelay)
        }

        @Test("Delay is within expected range for attempt 2")
        func delayRangeForAttempt2() {
            let policy = DefaultRetryPolicyTests.makePolicy()
            let delay = policy.delay(for: .init(attempt: 2, method: "GET", failure: .other))

            // base = 4.0, jitter = 0...1.0, range is 4.0...5.0 seconds
            let minDelay = UInt64(4.0 * 1_000_000_000)
            let maxDelay = UInt64(5.0 * 1_000_000_000)
            #expect(delay >= minDelay)
            #expect(delay <= maxDelay)
        }
    }
}

extension DefaultRetryPolicyTests {
    fileprivate static func makePolicy(maxRetries: Int = 3) -> DefaultRetryPolicy {
        DefaultRetryPolicy(maxRetries: maxRetries)
    }

    fileprivate static func assertShouldRetry(
        _ expected: Bool,
        context: RetryContext,
        maxRetries: Int = 3
    ) {
        let policy = makePolicy(maxRetries: maxRetries)
        #expect(policy.shouldRetry(context: context) == expected)
    }
}
