//
//  ExchangeDomainError.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeDomainError

enum ExchangeDomainError: Error, Sendable {
    case invalidRemoteData
    case ratesUnavailable
}
