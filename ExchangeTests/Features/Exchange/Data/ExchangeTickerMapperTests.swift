//
//  ExchangeTickerMapperTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 02/06/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("ExchangeTickerMapper")
struct ExchangeTickerMapperTests {
    // MARK: - Single DTO Mapping

    @Suite("Single DTO")
    struct SingleDTO {
        @Test("maps valid DTO to ExchangeRate with correct fields")
        func mapsValidDTO() {
            let dto = ExchangeTickerDTO(
                ask: "18.4105000000",
                bid: "18.4069700000",
                book: "usdc_mxn",
                date: "2025-10-20T20:14:57.361483956")

            let result = ExchangeTickerMapper.map(dto)

            #expect(result != nil)
            #expect(result?.baseCurrency.code == "USDC")
            #expect(result?.quoteCurrency.code == "MXN")
            #expect(result?.ask == decimal("18.4105000000"))
            #expect(result?.bid == decimal("18.4069700000"))
            #expect(result?.timestamp != nil)
        }

        @Test("returns nil for malformed book with no underscore")
        func returnsNilForMalformedBookNoUnderscore() {
            let dto = ExchangeTickerDTO(
                ask: "18.41",
                bid: "18.39",
                book: "usdcmxn",
                date: "2025-10-20T20:14:57.361483956")

            #expect(ExchangeTickerMapper.map(dto) == nil)
        }

        @Test("returns nil for book with multiple underscores")
        func returnsNilForBookWithMultipleUnderscores() {
            let dto = ExchangeTickerDTO(
                ask: "18.41",
                bid: "18.39",
                book: "usdc_mxn_extra",
                date: "2025-10-20T20:14:57.361483956")

            #expect(ExchangeTickerMapper.map(dto) == nil)
        }

        @Test("returns nil for empty book")
        func returnsNilForEmptyBook() {
            let dto = ExchangeTickerDTO(
                ask: "18.41",
                bid: "18.39",
                book: "",
                date: "2025-10-20T20:14:57.361483956")

            #expect(ExchangeTickerMapper.map(dto) == nil)
        }

        @Test("returns nil for non-numeric ask")
        func returnsNilForNonNumericAsk() {
            let dto = ExchangeTickerDTO(
                ask: "abc",
                bid: "18.39",
                book: "usdc_mxn",
                date: "2025-10-20T20:14:57.361483956")

            #expect(ExchangeTickerMapper.map(dto) == nil)
        }

        @Test("returns nil for non-numeric bid")
        func returnsNilForNonNumericBid() {
            let dto = ExchangeTickerDTO(
                ask: "18.41",
                bid: "not_a_number",
                book: "usdc_mxn",
                date: "2025-10-20T20:14:57.361483956")

            #expect(ExchangeTickerMapper.map(dto) == nil)
        }

        @Test("returns nil for unparseable date")
        func returnsNilForUnparseableDate() {
            let dto = ExchangeTickerDTO(
                ask: "18.41",
                bid: "18.39",
                book: "usdc_mxn",
                date: "not-a-date")

            #expect(ExchangeTickerMapper.map(dto) == nil)
        }

        @Test("parses ISO8601 date with timezone")
        func parsesISO8601WithTimezone() {
            let dto = ExchangeTickerDTO(
                ask: "18.41",
                bid: "18.39",
                book: "usdc_mxn",
                date: "2025-10-20T20:14:57.361Z")

            let result = ExchangeTickerMapper.map(dto)

            #expect(result != nil)
            #expect(result?.timestamp != nil)
        }

        @Test("parses fractional-second date without timezone")
        func parsesFractionalNoTimezone() {
            let dto = ExchangeTickerDTO(
                ask: "18.41",
                bid: "18.39",
                book: "usdc_mxn",
                date: "2025-10-20T20:14:57.361483956")

            let result = ExchangeTickerMapper.map(dto)

            #expect(result != nil)
            #expect(result?.timestamp != nil)
        }

        @Test("uppercases currency codes from book")
        func uppercasesCurrencyCodes() {
            let dto = ExchangeTickerDTO(
                ask: "1551.00",
                bid: "1539.00",
                book: "USDC_ars",
                date: "2025-10-21T09:44:18.512194175")

            let result = ExchangeTickerMapper.map(dto)

            #expect(result?.baseCurrency.code == "USDC")
            #expect(result?.quoteCurrency.code == "ARS")
        }
    }

    // MARK: - Batch Mapping

    @Suite("Batch Mapping")
    struct BatchMapping {
        @Test("maps array of valid DTOs")
        func mapsValidArray() {
            let dtos = [
                ExchangeTickerDTO(
                    ask: "18.41", bid: "18.39",
                    book: "usdc_mxn", date: "2025-10-20T20:14:57.361483956"),
                ExchangeTickerDTO(
                    ask: "1551.00", bid: "1539.00",
                    book: "usdc_ars", date: "2025-10-21T09:44:18.512194175"),
            ]

            let results = ExchangeTickerMapper.map(dtos)

            #expect(results.count == 2)
            #expect(results[0].quoteCurrency.code == "MXN")
            #expect(results[1].quoteCurrency.code == "ARS")
        }

        @Test("silently discards malformed entries from batch")
        func discardsMalformedFromBatch() {
            let dtos = [
                ExchangeTickerDTO(
                    ask: "18.41", bid: "18.39",
                    book: "usdc_mxn", date: "2025-10-20T20:14:57.361483956"),
                ExchangeTickerDTO(
                    ask: "bad", bid: "18.39",
                    book: "usdc_ars", date: "2025-10-21T09:44:18.512194175"),
                ExchangeTickerDTO(
                    ask: "100", bid: "99",
                    book: "invalidbook", date: "2025-10-21T09:44:18.512194175"),
            ]

            let results = ExchangeTickerMapper.map(dtos)

            #expect(results.count == 1)
            #expect(results[0].quoteCurrency.code == "MXN")
        }

        @Test("returns empty array for all-invalid input")
        func returnsEmptyForAllInvalid() {
            let dtos = [
                ExchangeTickerDTO(
                    ask: "bad", bid: "bad",
                    book: "no_underscore_wait_this_has_one", date: "bad"),
                ExchangeTickerDTO(
                    ask: "", bid: "",
                    book: "", date: ""),
            ]

            let results = ExchangeTickerMapper.map(dtos)

            #expect(results.isEmpty)
        }

        @Test("returns empty array for empty input")
        func returnsEmptyForEmptyInput() {
            let results = ExchangeTickerMapper.map([])

            #expect(results.isEmpty)
        }
    }
}

private func decimal(_ value: String) -> Decimal {
    Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) ?? .zero
}
