//
//  ViewModelProtocol.swift
//  Exchange
//

import Combine
import Foundation

@MainActor
protocol ViewModelProtocol: ObservableObject {
    associatedtype State
    associatedtype Trigger

    var state: State { get }
    func onTrigger(_ trigger: Trigger)
}
