//
//  CurrencyConverterAssembly.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 02/03/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation

enum CurrencyConverterFactory {
    static func makeView() -> CurrencyConverterViewController {
        let viewController = CurrencyConverterViewController()
        
        let currencyRatesService = CurrencyRatesServiceFactory.makeService()
        let currencyFormatter = CurrencyFormatter()
        let viewModel = CurrencyConverterViewModelImpl(currencyRatesService: currencyRatesService,
                                                       currencyFormatter: currencyFormatter)
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        
        return viewController
    }
}
