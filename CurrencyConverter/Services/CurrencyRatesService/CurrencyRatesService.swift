//
//  CurrencyRateService.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 25/02/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation

protocol CurrencyRatesService {
    func updateRates(сurrencyCode: String?,
                     completion: @escaping (Result<CurrencyRatesModel>) -> Void)
}

final class CurrencyRatesServiceImpl: CurrencyRatesService {
    private let urlSession: URLSession
    private let urlProvider: URLProvider
    
    init(urlProvider: URLProvider, urlSession: URLSession) {
        self.urlProvider = urlProvider
        self.urlSession = urlSession
    }
    
    func updateRates(сurrencyCode: String?,
                     completion: @escaping (Result<CurrencyRatesModel>) -> Void) {
        let url = urlProvider.makeCurencyRatesUrl(currencyCode: сurrencyCode)
        urlSession.dataTask(with: url) { (data, responce, error) in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let currencyRates = try decoder.decode(CurrencyRatesModel.self, from: data)
                    completion(.success(currencyRates))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(CurrencyRatesServiceError.unknown))
            }
        }.resume()
    }
}
