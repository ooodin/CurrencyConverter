//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Artem Semavin on 25/02/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

class CurrencyConverterTests: XCTestCase {
    func testCurrencyFormatter() {
        let currencyFormatter = CurrencyFormatter()
        
        let initialDoubleValue = 10.01
        let stringFormDouble = currencyFormatter.string(with: initialDoubleValue)
        let finalDoubleValue = currencyFormatter.number(with: stringFormDouble)
        
        XCTAssertEqual(initialDoubleValue, finalDoubleValue)
        
        let initialStringValue = "100.01"
        let doubleFromString = currencyFormatter.number(with: initialStringValue)
        let finalStringValue = currencyFormatter.string(with: doubleFromString)
        
        XCTAssertEqual(initialStringValue, finalStringValue)
    }
    
    func testCurrencyRatesService() {
        let service = CurrencyRatesServiceFactory.makeService()

        let expectation1 = self.expectation(description: "updateRates1")
        var currencyRates: CurrencyRatesModel?
        
        service.updateRates(сurrencyCode: nil) { result in
            switch result {
            case .success(let value):
                currencyRates = value
                expectation1.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(currencyRates)
        
        let expectation2 = self.expectation(description: "updateRates2")
        let initialCurrencyCode = "USD"
        
        service.updateRates(сurrencyCode: initialCurrencyCode) { result in
            switch result {
            case .success(let value):
                currencyRates = value
                expectation2.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        if let currencyRates = currencyRates {
            XCTAssertEqual(initialCurrencyCode, currencyRates.base)
        } else {
            XCTFail()
        }
    }
    
    func testCurrencyConverterViewModel() {
        let delegate = CurrencyConverterViewModelTestDelegate()
        let viewModel = CurrencyConverterViewModelFactory.makeViewModel(delegate: delegate)
        
        let expectationSetupView = self.expectation(description: "setupView")
        delegate.expectation = expectationSetupView
        viewModel.setupView()
        
        wait(for: [expectationSetupView], timeout: 1)
        XCTAssertGreaterThan(delegate.rates.count, 0)
 
        guard let lastRate = delegate.rates.last else {
            XCTFail("It seems, rates array is empty:(")
            return
        }
        let lastRateIndexPath = IndexPath(item: delegate.rates.count - 1, section: 0)
        let expectationSelectCurrency = self.expectation(description: "selectCurrency")
        delegate.expectation = expectationSelectCurrency
        viewModel.didSelectCurrency(at: lastRateIndexPath)

        wait(for: [expectationSelectCurrency], timeout: 0.5)
        let firstRate = delegate.rates.first
        XCTAssertEqual(lastRate.currencyCode, firstRate?.currencyCode)
    }
}
