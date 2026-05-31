//
//  GetAvailableCurrenciesUseCase.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - GetAvailableCurrenciesUseCase

struct GetAvailableCurrenciesUseCase {
    private let repository: ExchangeRepositoryProtocol

    init(repository: ExchangeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async -> [Currency] {
        await repository.fetchAvailableCurrencies()
    }
}
