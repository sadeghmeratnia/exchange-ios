//
//  Currency.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - Currency

struct Currency: Hashable, Sendable, Codable {
    let code: String

    init(code: String) {
        self.code = code.uppercased()
    }

    var isUSDc: Bool {
        code == "USDC"
    }
}
