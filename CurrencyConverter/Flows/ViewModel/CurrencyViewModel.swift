//
//  CurrencyViewModel.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 02/03/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation
import class UIKit.UIImage
import protocol DifferenceKit.Differentiable

struct CurrencyViewModel {
    let currencyCode: CurrencyCode
    let isEditable: Bool

    let title: String
    let subtitle: String
    let icon: UIImage
    let value: String
}

// MARK: - Differentiable

extension CurrencyViewModel: Differentiable {
    var differenceIdentifier: CurrencyCode {
        return currencyCode
    }
    
    func isContentEqual(to source: CurrencyViewModel) -> Bool {
        return currencyCode == source.currencyCode &&
            subtitle == source.subtitle &&
            value == source.value
    }
}
