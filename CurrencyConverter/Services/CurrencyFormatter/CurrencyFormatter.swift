//
//  CurrencyFormatter.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 04/03/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation

final class CurrencyFormatter {
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencyDecimalSeparator = Locale.current.decimalSeparator
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    func string(with doubleValue: Double) -> String {
        let value = NSNumber(value: doubleValue)
        return currencyFormatter.string(from: value) ?? ""
    }
    
    func number(with text: String) -> Double {
        let value = currencyFormatter.number(from: text) ?? 0
        return value.doubleValue
    }
    
    func currencyName(with code: String) -> String {
        return Locale.current.localizedString(forCurrencyCode: code) ?? ""
    }
}
