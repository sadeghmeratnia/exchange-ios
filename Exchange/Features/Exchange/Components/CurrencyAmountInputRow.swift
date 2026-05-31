//
//  CurrencyAmountInputRow.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - CurrencyAmountInputRow

struct CurrencyAmountInputRow: View {
    let currencyCode: String
    let amountText: String
    let isSelectableCurrency: Bool
    let onCurrencyTap: () -> Void
    let onAmountChanged: (String) -> Void

    var body: some View {
        HStack(spacing: UIConstants.Spacing.md) {
            Button {
                if isSelectableCurrency {
                    onCurrencyTap()
                }
            } label: {
                HStack(spacing: UIConstants.Spacing.sm) {
                    Text(flag(for: currencyCode))
                    Text(currencyTitle(for: currencyCode))
                        .font(.subheadline.weight(.semibold))
                    if isSelectableCurrency {
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                }
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)

            Spacer()

            TextField("0", text: Binding(get: { amountText }, set: onAmountChanged))
                .font(.body.weight(.semibold))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 150)
        }
        .padding(.horizontal, UIConstants.Spacing.md)
        .padding(.vertical, UIConstants.Spacing.lg)
    }
}

private extension CurrencyAmountInputRow {
    func currencyTitle(for code: String) -> String {
        code == "USDC" ? "USDc" : code
    }

    func flag(for code: String) -> String {
        switch code {
        case "USDC":
            "🇺🇸"
        case "MXN":
            "🇲🇽"
        case "ARS":
            "🇦🇷"
        case "BRL":
            "🇧🇷"
        case "COP":
            "🇨🇴"
        default:
            "🏳️"
        }
    }
}
