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

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 30, height: 30)
                Image(systemName: "arrow.up.arrow.down")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}
