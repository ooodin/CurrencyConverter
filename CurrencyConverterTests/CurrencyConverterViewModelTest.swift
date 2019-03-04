//
//  CurrencyConverterViewModelTest.swift
//  CurrencyConverterTests
//
//  Created by Artem Semavin on 04/03/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

enum CurrencyConverterViewModelFactory {
    static func makeViewModel(delegate: CurrencyConverterViewModelDelegate) -> CurrencyConverterViewModel {
        let currencyRatesService = CurrencyRatesServiceFactory.makeService()
        let currencyFormatter = CurrencyFormatter()
        let viewModel = CurrencyConverterViewModelImpl(currencyRatesService: currencyRatesService,
                                                       currencyFormatter: currencyFormatter)
        viewModel.delegate = delegate
        return viewModel
    }
}

class CurrencyConverterViewModelTestDelegate: CurrencyConverterViewModelDelegate {
    
    var rates: [CurrencyViewModel] = []
    var expectation: XCTestExpectation?
    
    func didUpdateCurrencyRates(_ rates: [CurrencyViewModel]) {
        guard let expectation = expectation else {
            XCTFail("expectation must be setted")
            return
        }
        self.rates = rates
        expectation.fulfill()
    }
}
