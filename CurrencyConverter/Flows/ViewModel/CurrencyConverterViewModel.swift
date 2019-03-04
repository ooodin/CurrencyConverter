//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 02/03/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation
import UIKit

protocol CurrencyConverterViewModel {
    var delegate: CurrencyConverterViewModelDelegate? { get set }
    
    func setupView()
    func didSelectCurrency(at index: IndexPath)
    func didEditBaseCurrencyValue(_ value: String?)
}

protocol CurrencyConverterViewModelDelegate: class {
    func didUpdateCurrencyRates(_ rates: [CurrencyViewModel])
}

final class CurrencyConverterViewModelImpl: CurrencyConverterViewModel {
    weak var delegate: CurrencyConverterViewModelDelegate?

    private let currencyFormatter: CurrencyFormatter
    private let currencyRatesService: CurrencyRatesService
    private let updateOperationQueue: OperationQueue
    
    private var currentBaseCurrencyCode: CurrencyCode?
    private var currentBaseCurrencyAmount: String?
    private var currentCurrencyModels: [CurrencyViewModel] = []
    
    private let highestPriority = Int.max
    private var currencyPriority: [CurrencyCode: Int] = [:]
    
    // MARK: - Initializer
    
    init(currencyRatesService: CurrencyRatesService, currencyFormatter: CurrencyFormatter) {
        self.currencyRatesService = currencyRatesService
        self.currencyFormatter = currencyFormatter
        
        let upateOperationQueue = OperationQueue()
        upateOperationQueue.name = "CurrencyConverter.upateOperationQueue"
        upateOperationQueue.qualityOfService = .default
        upateOperationQueue.maxConcurrentOperationCount = 1
        
        self.updateOperationQueue = upateOperationQueue
    }
    
    // MARK: - CurrencyConverterViewModel protocol
    
    func setupView() {
        currentBaseCurrencyCode = Constants.defaultCurrencyCode
        currentBaseCurrencyAmount = currencyFormatter.string(with: Constants.defaultCurrencyAmount)
        updateCurrencyRates()
    }
    
    func didEditBaseCurrencyValue(_ value: String?) {
        currentBaseCurrencyAmount = value
    }
    
    func didSelectCurrency(at index: IndexPath) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self, self.currentCurrencyModels.indices.contains(index.row) else {
                assertionFailure("currentCurrencyRates doesn't contains index")
                return
            }
            var currencyViewModels = self.currentCurrencyModels
            let selectedCurrency = currencyViewModels.remove(at: index.row)
            currencyViewModels.insert(selectedCurrency, at: 0)
            
            self.updateCurrencyViewModels(with: currencyViewModels)
        }
    }
    
    // MARK: - Private

    private func updateCurrencyAttributes() {
        let baseCurrency = currentCurrencyModels.first
        currentBaseCurrencyCode = baseCurrency?.currencyCode
        currentBaseCurrencyAmount = baseCurrency?.value
        
        currencyPriority.removeAll()
        currentCurrencyModels.enumerated().forEach {
            currencyPriority[$0.element.currencyCode] = $0.offset
        }
    }
    
    private func updateCurrencyViewModels(with currencyViewModels: [CurrencyViewModel]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let delegate = self.delegate else { return }
            self.currentCurrencyModels = currencyViewModels
            self.updateCurrencyAttributes()
            delegate.didUpdateCurrencyRates(currencyViewModels)
        }
    }

    private func updateCurrencyRates() {
        updateOperationQueue.cancelAllOperations()
        updateOperationQueue.addOperation { [weak self] in
            let сurrencyCode = self?.currentBaseCurrencyCode
            self?.currencyRatesService.updateRates(сurrencyCode: сurrencyCode) { result in
                guard let self = self else { return }
                switch result {
                case .success(let rates):
                    self.didSuccessUpdateRates(rates)
                case .failure(let error):
                    self.didFailUpdateRates(error: error)
                }
            }
        }
    }

    private func didSuccessUpdateRates(_ rates: CurrencyRatesModel) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, rates.base == self.currentBaseCurrencyCode else { return }
            let baseValue = self.currentBaseCurrencyAmount ?? ""
            let currencyViewModels = self.makeCurrencyViewModels(rates, baseCurrencyValue: baseValue)
            self.updateCurrencyViewModels(with: currencyViewModels)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.updateDelay) { [weak self] in
            self?.updateCurrencyRates()
        }
    }
    
    private func didFailUpdateRates(error: Error) {
        // ToDo: - handle errors
        NSLog("Error: %@", error.localizedDescription)
    }
    
    private func makeCurrencyViewModels(_ currencyRates: CurrencyRatesModel,
                                        baseCurrencyValue: String) -> [CurrencyViewModel] {
        var currencyViewModels: [CurrencyViewModel] = []
        
        let currencyAmount = currencyFormatter.number(with: baseCurrencyValue)
        let currencyIcon = #imageLiteral(resourceName: "currency.pdf")
        
        let baseCurrencySubtitle = currencyFormatter.currencyName(with: currencyRates.base)
        
        let baseCurrencyModel = CurrencyViewModel(currencyCode: currencyRates.base,
                                                  isEditable: true,
                                                  title: currencyRates.base.uppercased(),
                                                  subtitle: baseCurrencySubtitle,
                                                  icon: currencyIcon,
                                                  value: baseCurrencyValue)
        currencyViewModels.append(baseCurrencyModel)
        
        for currencyRateItem in currencyRates.rates {
            let currencyCode = currencyRateItem.key
            let currencyRate = currencyRateItem.value
            
            let currencySubtitle = currencyFormatter.currencyName(with: currencyCode)
            let currencyValue = currencyFormatter.string(with: currencyAmount * currencyRate)
            let currencyModel = CurrencyViewModel(currencyCode: currencyCode,
                                                  isEditable: false,
                                                  title: currencyCode.uppercased(),
                                                  subtitle: currencySubtitle,
                                                  icon: currencyIcon,
                                                  value: currencyValue)
            currencyViewModels.append(currencyModel)
        }
        
        currencyViewModels.sort {
            let priority1 = currencyPriority[$0.currencyCode] ?? highestPriority
            let priority2 = currencyPriority[$1.currencyCode] ?? highestPriority
            return priority1 < priority2
        }
        return currencyViewModels
    }
}

// MARK: - Constants

private extension CurrencyConverterViewModelImpl {
    enum Constants {
        static let updateDelay: Double = 1
        static let defaultCurrencyCode = "EUR"
        static let defaultCurrencyAmount: Double = 100
    }
}
