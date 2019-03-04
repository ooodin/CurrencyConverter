//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 02/03/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

final class CurrencyConverterViewController: UITableViewController {
    
    //MARK: - Property
    
    var viewModel: CurrencyConverterViewModel?
    private var currencyRates: [CurrencyViewModel] = []
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        guard let viewModel = viewModel else {
            assertionFailure("Error viewModel didn't set")
            return
        }
        viewModel.setupView()
    }

    // MARK: - Private methods
    
    private func setupView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Space.double + Space.quadruple
        
        tableView.register(CurrencyTableViewCell.self,
                           forCellReuseIdentifier: Constants.currencyRateCellId)
    }
    
    private func updateCellValue(at indexPath: IndexPath,
                                 with model: CurrencyViewModel) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CurrencyTableViewCell else {
            return
        }
        cell.value = model.value
    }
}

// MARK: - UITableViewControllerDataSource

extension CurrencyConverterViewController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return currencyRates.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard currencyRates.indices.contains(indexPath.row) else {
            assertionFailure("dataSource doesn't containt index")
            return UITableViewCell()
        }
        let model = currencyRates[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currencyRateCellId)
        
        guard let currencyCell = cell as? CurrencyTableViewCell else {
            assertionFailure("tableView didn't register cell for identifier")
            return UITableViewCell()
        }
        currencyCell.title = model.title
        currencyCell.subtitle = model.subtitle
        currencyCell.value = model.value
        currencyCell.icon = model.icon
        currencyCell.isEditable = model.isEditable
        currencyCell.setValueEditSelector(#selector(textValueDidChange(_:)))
    
        return currencyCell
    }
}

// MARK: - UITableViewControllerDelegate

extension CurrencyConverterViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let startIndexPath = IndexPath(row: 0, section: 0)
        if let topCell = tableView.cellForRow(at: startIndexPath) as? CurrencyTableViewCell {
            topCell.isEditable = false
            topCell.setResignFirstResponder()
        }
        if let selectedCell = tableView.cellForRow(at: indexPath) as? CurrencyTableViewCell {
            selectedCell.isEditable = true
            selectedCell.setBecomeFirstResponder()
        }
        viewModel?.didSelectCurrency(at: indexPath)
    }
}

// MARK: - CurrencyConverterViewModelDelegate

extension CurrencyConverterViewController: CurrencyConverterViewModelDelegate {
    func didUpdateCurrencyRates(_ rates: [CurrencyViewModel]) {
        let stagedChangeset = StagedChangeset(source: currencyRates, target: rates)
        
        for changeset in stagedChangeset {
            tableView.beginUpdates()
            currencyRates = changeset.data
            
            if !changeset.elementDeleted.isEmpty {
                let deleteRows = changeset.elementDeleted.map { IndexPath(row: $0.element, section: $0.section) }
                tableView.deleteRows(at: deleteRows, with: .none)
            }
            
            if !changeset.elementInserted.isEmpty {
                let insertRows = changeset.elementInserted.map { IndexPath(row: $0.element, section: $0.section) }
                tableView.insertRows(at: insertRows, with: .none)
            }
            
            for (source, target) in changeset.elementMoved {
                let at = IndexPath(row: source.element, section: source.section)
                let to = IndexPath(row: target.element, section: target.section)
                tableView.moveRow(at: at, to: to)
            }
            tableView.endUpdates()
            
            changeset.elementUpdated.forEach {
                guard currencyRates.indices.contains($0.element) else { return }
                let indexPath = IndexPath(row: $0.element, section: $0.section)
                let model = currencyRates[$0.element]
                updateCellValue(at: indexPath, with: model)
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension CurrencyConverterViewController: UITextFieldDelegate {
    @objc
    func textValueDidChange(_ sender: UITextField) {
        viewModel?.didEditBaseCurrencyValue(sender.text)
    }
}

// MARK: - Constants

private extension CurrencyConverterViewController {
    enum Constants {
        static let currencyRateCellId = "currencyRateCellId"
    }
}
