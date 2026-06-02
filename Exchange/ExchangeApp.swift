//
//  ExchangeApp.swift
//  Exchange
//
//  Created by Sadegh on 30/05/2026.
//

import Foundation
import SwiftUI

@main
struct ExchangeApp: App {
    private let appContainer: AppContainer

    init() {
        self.appContainer = .live()
    }

    var body: some Scene {
        WindowGroup {
            ExchangeFeatureBuilder(appContainer: appContainer).makeRootView()
        }
    }
}
