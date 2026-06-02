//
//  ExchangeDomainError.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeDomainError

enum ExchangeDomainError: Error, Sendable, Equatable, LocalizedError {
    case invalidRemoteData
    case ratesUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidRemoteData:
            L10n.Exchange.Error.invalidRemoteData
        case .ratesUnavailable:
            L10n.Exchange.Error.ratesUnavailable
        }
    }
}
