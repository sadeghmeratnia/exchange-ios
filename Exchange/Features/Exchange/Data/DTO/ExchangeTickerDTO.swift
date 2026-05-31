//
//  ExchangeTickerDTO.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeTickerDTO

struct ExchangeTickerDTO: Decodable, Sendable {
    let ask: String
    let bid: String
    let book: String
    let date: String
}
