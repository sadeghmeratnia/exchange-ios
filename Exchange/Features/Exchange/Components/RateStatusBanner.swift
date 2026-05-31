//
//  RateStatusBanner.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - RateStatusBanner

struct RateStatusBanner: View {
    let text: String
    let isRealtime: Bool

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(isRealtime ? .green : .orange)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
