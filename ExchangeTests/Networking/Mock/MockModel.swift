//
//  MockModel.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

@testable import Exchange
import Foundation

struct MockModel: Codable, Equatable, Sendable {
    let id: Int
    let name: String
}
