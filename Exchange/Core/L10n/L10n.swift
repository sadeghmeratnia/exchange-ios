//
//  L10n.swift
//  Exchange
//

import Foundation

enum L10n {
    enum Exchange {
        static var calculatorTitle: String {
            tr(.exchangeCalculatorTitle)
        }

        enum CurrencyPicker {
            static var title: String {
                tr(.exchangeCurrencyPickerTitle)
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

    private enum Key: String {
        case exchangeCalculatorTitle = "exchange.calculator.title"
        case exchangeCurrencyPickerTitle = "exchange.currencyPicker.title"
        case exchangeStatusLive = "exchange.status.live"
        case exchangeStatusNotRealtime = "exchange.status.notRealtime"
        case exchangeStatusUpdated = "exchange.status.updated"
        case exchangeStatusLastUpdated = "exchange.status.lastUpdated"
    }

    private static func tr(_ key: Key) -> String {
        let localized = NSLocalizedString(
            key.rawValue,
            tableName: nil,
            bundle: .main,
            value: "",
            comment: "")
        #if DEBUG
            assert(localized.isEmpty == false, "Missing localization key: \(key.rawValue)")
        #endif
        return localized.isEmpty ? key.rawValue : localized
    }
}
