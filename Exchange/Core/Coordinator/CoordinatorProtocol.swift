//
//  CoordinatorProtocol.swift
//  Exchange
//
//  Created by Sadegh on 01/06/2026.
//

import SwiftUI

@MainActor
protocol CoordinatorProtocol {
    associatedtype RootView: View
    @ViewBuilder
    func makeRootView() -> RootView
}
