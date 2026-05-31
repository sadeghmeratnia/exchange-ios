//
//  ViewModelProtocol.swift
//  Exchange
//
//  Created by Sadegh on 30/05/2026.
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
