//
//  SwapButton.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - SwapButton

struct SwapButton: View {
    let onTap: () -> Void
    @State private var rotationDegrees: Double = 0

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                rotationDegrees += 180
            }
            onTap()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 30, height: 30)
                Image(systemName: "arrow.up.arrow.down")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(rotationDegrees))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Swap currencies")
        .accessibilityIdentifier(AccessibilityID.swapButton)
    }
}
