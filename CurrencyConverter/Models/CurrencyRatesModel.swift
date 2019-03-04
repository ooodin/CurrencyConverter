//
//  CurrencyRate.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 25/02/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation

typealias CurrencyCode = String

struct CurrencyRatesModel: Decodable {
    let base: CurrencyCode
    let rates: [CurrencyCode: Double]
}
