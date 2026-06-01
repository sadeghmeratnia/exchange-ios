//
//  L10n.swift
//  Exchange
//
//  Created by Sadegh on 30/05/2026.
//

import Foundation

enum L10n {
    enum Exchange {
        static var calculatorTitle: String {
            tr(.exchangeCalculatorTitle)
        }

        enum Action {
            static var retry: String {
                tr(.exchangeActionRetry)
            }
        }

        enum CurrencyPicker {
            static var title: String {
                tr(.exchangeCurrencyPickerTitle)
            }
        }

        enum Accessibility {
            static var currency: String {
                tr(.exchangeAccessibilityCurrency)
            }
        }

        enum Status {
            static var live: String {
                tr(.exchangeStatusLive)
            }

            static var notRealtime: String {
                tr(.exchangeStatusNotRealtime)
            }

            static var updated: String {
                tr(.exchangeStatusUpdated)
            }

            static var lastUpdated: String {
                tr(.exchangeStatusLastUpdated)
            }
        }
    }

    private enum Key: String.LocalizationValue {
        case exchangeCalculatorTitle = "exchange.calculator.title"
        case exchangeActionRetry = "exchange.action.retry"
        case exchangeCurrencyPickerTitle = "exchange.currencyPicker.title"
        case exchangeAccessibilityCurrency = "exchange.accessibility.currency"
        case exchangeStatusLive = "exchange.status.live"
        case exchangeStatusNotRealtime = "exchange.status.notRealtime"
        case exchangeStatusUpdated = "exchange.status.updated"
        case exchangeStatusLastUpdated = "exchange.status.lastUpdated"
    }

    private static func tr(_ key: Key) -> String {
        String(localized: key.rawValue)
    }
}
