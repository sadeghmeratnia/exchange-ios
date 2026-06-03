//
//  ExchangeUITests.swift
//  ExchangeUITests
//
//  Created by Sadegh on 30/05/2026.
//

import XCTest

final class ExchangeUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testCalculatorScreenLoadsWithExpectedElements() throws {
        let screen = app.otherElements[AccessibilityID.exchangeListScreen]
        XCTAssertTrue(screen.waitForExistence(timeout: 5))

        XCTAssertTrue(app.buttons[AccessibilityID.swapButton].exists)
        XCTAssertTrue(app.textFields[AccessibilityID.amountField(currencyCode: "USDC")].exists)
        XCTAssertTrue(app.textFields[AccessibilityID.amountField(currencyCode: "MXN")].exists)
    }

    @MainActor
    func testSwapButtonFlipsCurrencies() throws {
        let topFieldBefore = app.textFields[AccessibilityID.amountField(currencyCode: "USDC")]
        XCTAssertTrue(topFieldBefore.waitForExistence(timeout: 5))

        app.buttons[AccessibilityID.swapButton].tap()

        let topFieldAfterSwap = app.textFields[AccessibilityID.amountField(currencyCode: "MXN")]
        XCTAssertTrue(topFieldAfterSwap.waitForExistence(timeout: 3),
                       "After swap, MXN should be in the top position")

        let bottomFieldAfterSwap = app.textFields[AccessibilityID.amountField(currencyCode: "USDC")]
        XCTAssertTrue(bottomFieldAfterSwap.exists,
                       "After swap, USDC should be in the bottom position")
    }

    @MainActor
    func testTypingAmountUpdatesOppositeField() throws {
        let topField = app.textFields[AccessibilityID.amountField(currencyCode: "USDC")]
        XCTAssertTrue(topField.waitForExistence(timeout: 5))

        topField.tap()
        topField.clearAndTypeText("100")

        let bottomField = app.textFields[AccessibilityID.amountField(currencyCode: "MXN")]
        let predicate = NSPredicate(format: "value != nil AND value != '' AND value != '0'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: bottomField)
        let result = XCTWaiter().wait(for: [expectation], timeout: 10)
        XCTAssertEqual(result, .completed,
                       "Bottom field should display a converted amount after typing in the top field")
    }
}

private extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let currentValue = value as? String, !currentValue.isEmpty else {
            typeText(text)
            return
        }
        tap()
        let selectAll = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        typeText(selectAll)
        typeText(text)
    }
}
