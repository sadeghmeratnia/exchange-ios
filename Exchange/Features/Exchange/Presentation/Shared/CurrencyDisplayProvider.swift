//
//  CurrencyDisplayProvider.swift
//  Exchange
//
//  Created by Sadegh on 01/06/2026.
//

import Foundation

struct CurrencyDisplay: Equatable {
    let code: String
    let title: String
    let flagEmoji: String?
    let fallbackSymbolName: String?
}

protocol CurrencyDisplayProviding {
    func display(for code: String) -> CurrencyDisplay
}

struct CurrencyDisplayProvider: CurrencyDisplayProviding {
    func display(for code: String) -> CurrencyDisplay {
        Self.display(for: code)
    }

    static func display(for code: String) -> CurrencyDisplay {
        let normalizedCode = code.uppercased()
        let title = normalizedCode == "USDC" ? "USDc" : normalizedCode
        let region = representativeRegion(for: normalizedCode)
        let flag = flagEmoji(from: region)

        return CurrencyDisplay(
            code: normalizedCode,
            title: title,
            flagEmoji: flag,
            fallbackSymbolName: flag == nil ? "globe" : nil)
    }
}

private extension CurrencyDisplayProvider {
    static let inferredRepresentativeRegions: [String: String] = {
        var regionsByCurrency: [String: Set<String>] = [:]
        for identifier in Locale.availableIdentifiers {
            let locale = Locale(identifier: identifier)
            guard let currencyCode = locale.currency?.identifier.uppercased(),
                  let regionCode = locale.region?.identifier.uppercased(),
                  regionCode.count == 2 else {
                continue
            }
            regionsByCurrency[currencyCode, default: []].insert(regionCode)
        }

        return regionsByCurrency.compactMapValues { regions in
            let sortedRegions = regions.sorted()
            if let currentRegion = Locale.current.region?.identifier.uppercased(),
               sortedRegions.contains(currentRegion) {
                return currentRegion
            }
            return sortedRegions.first
        }
    }()

    static func representativeRegion(for currencyCode: String) -> String? {
        if currencyCode == "USDC" {
            return "US"
        }
        return inferredRepresentativeRegions[currencyCode]
    }

    static func flagEmoji(from countryCode: String?) -> String? {
        guard let countryCode,
              countryCode.count == 2 else {
            return nil
        }

        let uppercased = countryCode.uppercased()
        let scalars = uppercased.unicodeScalars.compactMap { scalar -> UnicodeScalar? in
            let ascii = scalar.value
            guard (65 ... 90).contains(ascii) else { return nil }
            let regionalIndicator = ascii + 127397
            return UnicodeScalar(regionalIndicator)
        }

        guard scalars.count == 2 else {
            return nil
        }

        return String(String.UnicodeScalarView(scalars))
    }
}
