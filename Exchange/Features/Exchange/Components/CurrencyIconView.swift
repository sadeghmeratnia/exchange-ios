//
//  CurrencyIconView.swift
//  Exchange
//
//  Created by Sadegh on 02/06/2026.
//

import SwiftUI

// MARK: - CurrencyIconView

struct CurrencyIconView: View {
    let display: CurrencyDisplay

    var body: some View {
        if let flag = display.flagEmoji {
            Text(flag)
                .accessibilityHidden(true)
        } else {
            Image(systemName: display.fallbackSymbolName ?? "globe")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityLabel(L10n.Exchange.Accessibility.currency)
        }
    }
}
