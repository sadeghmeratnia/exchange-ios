//
//  ExchangeTickerMapper.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeTickerMapper

struct ExchangeTickerMapper {
    static func map(_ dto: ExchangeTickerDTO) -> ExchangeRate? {
        let bookParts = dto.book.split(separator: "_").map { String($0).uppercased() }
        guard bookParts.count == 2 else { return nil }
        guard let ask = Decimal(string: dto.ask, locale: Locale(identifier: "en_US_POSIX")),
              let bid = Decimal(string: dto.bid, locale: Locale(identifier: "en_US_POSIX")),
              let timestamp = parseDate(dto.date) else {
            return nil
        }

        return ExchangeRate(
            baseCurrency: Currency(code: bookParts[0]),
            quoteCurrency: Currency(code: bookParts[1]),
            ask: ask,
            bid: bid,
            timestamp: timestamp)
    }

    static func map(_ dtos: [ExchangeTickerDTO]) -> [ExchangeRate] {
        dtos.compactMap(map)
    }

    private static func parseDate(_ rawDate: String) -> Date? {
        if let date = Formatter.iso8601WithTimeZone.date(from: rawDate) {
            return date
        }
        return Formatter.iso8601FractionalNoTimeZone.date(from: rawDate)
    }
}

private enum Formatter {
    static let iso8601WithTimeZone: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let iso8601FractionalNoTimeZone: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS"
        return formatter
    }()
}
