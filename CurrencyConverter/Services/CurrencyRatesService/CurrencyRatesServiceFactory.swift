//
//  CurrencyRatesServiceFactory.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 26/02/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation

enum CurrencyRatesServiceFactory {
    static func makeService() -> CurrencyRatesService {
        let urlSession = URLSession(configuration: .default)
        let urlProvider = URLProvider()
        
        return CurrencyRatesServiceImpl(urlProvider: urlProvider,
                                        urlSession: urlSession)
    }
}
