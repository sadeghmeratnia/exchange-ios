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
    let autoFocusOnAppear: Bool
    let onCurrencyTap: () -> Void
    let onAmountChanged: (String) -> Void
    private let currencyDisplayProvider: any CurrencyDisplayProviding
    @FocusState private var isAmountFieldFocused: Bool
    @State private var didAutoFocus = false
    @State private var shakeOffset: CGFloat = 0

    init(currencyCode: String,
         amountText: String,
         isSelectableCurrency: Bool,
         autoFocusOnAppear: Bool = false,
         onCurrencyTap: @escaping () -> Void,
         onAmountChanged: @escaping (String) -> Void,
         currencyDisplayProvider: any CurrencyDisplayProviding = CurrencyDisplayProvider()) {
        self.currencyCode = currencyCode
        self.amountText = amountText
        self.isSelectableCurrency = isSelectableCurrency
        self.autoFocusOnAppear = autoFocusOnAppear
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
                    CurrencyIconView(display: display)
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

            TextField("", text: Binding(get: { amountText }, set: { newValue in
                    onAmountChanged(newValue)
                    if !newValue.isEmpty,
                       LocalizedNumberFormatting.parseDecimalInput(newValue) == nil {
                        triggerInvalidInputFeedback()
                    }
                }))
                .font(.body.weight(.semibold))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 150)
                .focused($isAmountFieldFocused)
                .offset(x: shakeOffset)
                .accessibilityLabel("Amount in \(display.title)")
                .accessibilityIdentifier("amountField_\(currencyCode)")
        }
        .padding(.horizontal, UIConstants.Spacing.md)
        .padding(.vertical, UIConstants.Spacing.lg)
        .onAppear {
            guard autoFocusOnAppear, didAutoFocus == false else { return }
            didAutoFocus = true
            Task { @MainActor in
                isAmountFieldFocused = true
            }
        }
    }

    private func triggerInvalidInputFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        withAnimation(.default.speed(3).repeatCount(3, autoreverses: true)) {
            shakeOffset = 4
        } completion: {
            shakeOffset = 0
        }
    }
}
