//
//  StaticViewModel.swift
//  Exchange
//

import Combine
import Foundation

@MainActor
final class StaticViewModel<State, Trigger>: ViewModelProtocol {
    @Published private(set) var state: State
    private let onTriggerHandler: ((Trigger) -> Void)?

    init(state: State, onTrigger: ((Trigger) -> Void)? = nil) {
        self.state = state
        self.onTriggerHandler = onTrigger
    }

    func onTrigger(_ trigger: Trigger) {
        onTriggerHandler?(trigger)
    }
}
