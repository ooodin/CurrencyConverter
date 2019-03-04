//
//  URLProvider.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 26/02/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation

struct URLProvider {
    func makeCurencyRatesUrl(currencyCode: String?) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = Parameters.Network.baseScheme
        urlComponents.host = Parameters.Network.baseURL
        urlComponents.path = Parameters.Network.currencyRatePath
        
        if let currencyCode = currencyCode {
            let currencyParameter = URLQueryItem(name: "base", value: currencyCode)
            urlComponents.queryItems = [currencyParameter]
        }
        return urlComponents.url!
    }
}
