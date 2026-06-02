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
    private let currencyDisplayProvider: any CurrencyDisplayProviding

    init(currencyCode: String,
         amountText: String,
         isSelectableCurrency: Bool,
         onCurrencyTap: @escaping () -> Void,
         onAmountChanged: @escaping (String) -> Void,
         currencyDisplayProvider: any CurrencyDisplayProviding = CurrencyDisplayProvider()) {
        self.currencyCode = currencyCode
        self.amountText = amountText
        self.isSelectableCurrency = isSelectableCurrency
        self.onCurrencyTap = onCurrencyTap
        self.onAmountChanged = onAmountChanged
        self.currencyDisplayProvider = currencyDisplayProvider
    }

    var body: some View {
        let display = currencyDisplayProvider.display(for: currencyCode)
        HStack(spacing: UIConstants.Spacing.md) {
            Button {
                if isSelectableCurrency {
                    onCurrencyTap()
                }
            } label: {
                HStack(spacing: UIConstants.Spacing.sm) {
                    currencyIcon(for: display)
                    Text(display.title)
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

            TextField("", text: Binding(get: { amountText }, set: onAmountChanged))
                .font(.body.weight(.semibold))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 150)
                .accessibilityLabel("Amount in \(display.title)")
        }
        .padding(.horizontal, UIConstants.Spacing.md)
        .padding(.vertical, UIConstants.Spacing.lg)
    }

    @ViewBuilder
    private func currencyIcon(for display: CurrencyDisplay) -> some View {
        if let flag = display.flagEmoji {
            Text(flag)
                .accessibilityHidden(true)
        } else {
            Image(systemName: display.fallbackSymbolName ?? "globe")
                .font(.subheadline)
                .accessibilityLabel(L10n.Exchange.Accessibility.currency)
        }
    }
}
