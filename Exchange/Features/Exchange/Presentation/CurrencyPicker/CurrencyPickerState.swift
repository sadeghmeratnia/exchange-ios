//
//  CurrencyPickerState.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - CurrencyPickerState

struct CurrencyPickerState: Equatable {
    var currencies: [Currency]
    var selectedCurrencyCode: String
    var isLoading: Bool

    init(currencies: [Currency] = [],
         selectedCurrencyCode: String = "",
         isLoading: Bool = false) {
        self.currencies = currencies
        self.selectedCurrencyCode = selectedCurrencyCode
        self.isLoading = isLoading
    }
}
