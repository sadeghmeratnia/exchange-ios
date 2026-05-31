//
//  ReducingStoreProtocol.swift
//  Exchange
//
//  Created by Sadegh on 30/05/2026.
//

import Foundation

@MainActor
protocol ReducingStoreProtocol: ViewModelProtocol {
    associatedtype Action
    associatedtype Effect

    func send(_ action: Action)
    func run(_ effect: Effect) async
}
