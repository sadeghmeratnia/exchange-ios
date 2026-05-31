//
//  ExchangeDetailState.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeDetailState

struct ExchangeDetailState: Equatable {
    var currencyCode: String
    var title: String

    static func initial(currencyCode: String) -> ExchangeDetailState {
        ExchangeDetailState(
            currencyCode: currencyCode,
            title: "Currency Details")
    }
}
