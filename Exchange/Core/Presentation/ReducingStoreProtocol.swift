//
//  ReducingStoreProtocol.swift
//  Exchange
//

import Foundation

@MainActor
protocol ReducingStoreProtocol: ViewModelProtocol {
    associatedtype Action
    associatedtype Effect

    func send(_ action: Action)
    func run(_ effect: Effect) async
}
