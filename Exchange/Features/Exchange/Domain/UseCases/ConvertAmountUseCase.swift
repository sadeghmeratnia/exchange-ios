//
//  ConvertAmountUseCase.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ConvertAmountUseCase

struct ConvertAmountUseCase {
    func execute(amount: Decimal,
                 from fromCurrency: Currency,
                 to toCurrency: Currency,
                 rates: [ExchangeRate]) -> Decimal? {
        guard fromCurrency != toCurrency else {
            return amount
        }

        let converted: Decimal?
        if fromCurrency.isUSDc {
            converted = convertFromUSDc(amount: amount, to: toCurrency, rates: rates)
        } else if toCurrency.isUSDc {
            converted = convertToUSDc(amount: amount, from: fromCurrency, rates: rates)
        } else {
            guard let usdcAmount = convertToUSDc(amount: amount, from: fromCurrency, rates: rates) else {
                return nil
            }
            converted = convertFromUSDc(amount: usdcAmount, to: toCurrency, rates: rates)
        }

        guard let converted else {
            return nil
        }
        return round(converted, scale: 6)
    }

    private func midRate(for rate: ExchangeRate) -> Decimal {
        (rate.ask + rate.bid) / 2
    }

    private func convertFromUSDc(amount: Decimal, to quoteCurrency: Currency, rates: [ExchangeRate]) -> Decimal? {
        guard let rate = rates.first(where: { $0.baseCurrency.isUSDc && $0.quoteCurrency == quoteCurrency }) else {
            return nil
        }
        return amount * midRate(for: rate)
    }

    private func convertToUSDc(amount: Decimal, from quoteCurrency: Currency, rates: [ExchangeRate]) -> Decimal? {
        guard let rate = rates.first(where: { $0.baseCurrency.isUSDc && $0.quoteCurrency == quoteCurrency }) else {
            return nil
        }
        let mid = midRate(for: rate)
        guard mid != .zero else { return nil }
        return amount / mid
    }

    private func round(_ value: Decimal, scale: Int) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, scale, .bankers)
        return output
    }
}
