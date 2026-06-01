//
//  GetExchangeRatesUseCase.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - GetExchangeRatesUseCase

struct GetExchangeRatesUseCase {
    private let repository: ExchangeRepositoryProtocol

    init(repository: ExchangeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(currencies: [String]) async throws -> ExchangeRatesSnapshot {
        try await repository.fetchRates(for: currencies)
    }
}
