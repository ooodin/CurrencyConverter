//
//  Result.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 25/02/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}
