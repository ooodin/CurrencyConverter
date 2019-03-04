//
//  CurrencyTableViewCell.swift
//  CurrencyConverter
//
//  Created by Artem Semavin on 02/03/2019.
//  Copyright © 2019 Semavin Artem. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text
        }
    }
    
    var subtitle: String? {
        set {
            subtitleLabel.text = newValue
        }
        get {
            return subtitleLabel.text
        }
    }
    
    var value: String? {
        set {
            valueTextField.text = newValue
        }
        get {
            return valueTextField.text
        }
    }
    
    var icon: UIImage? {
        set {
            iconImageView.image = newValue
        }
        get {
            return iconImageView.image
        }
    }
    
    var isEditable: Bool {
        set {
            valueTextField.isUserInteractionEnabled = newValue
        }
        get {
            return valueTextField.isUserInteractionEnabled
        }
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var valueTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private

    private func setupView() {
        [
            titleLabel,
            subtitleLabel,
            valueTextField,
            iconImageView,
        ]
        .forEach { [weak contentView] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView?.addSubview($0)
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Space.quadruple),
            iconImageView.heightAnchor.constraint(equalToConstant: Space.quadruple),
            
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Space.single),
            iconImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Space.double),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Space.single),
            titleLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: Space.single),
            titleLabel.rightAnchor.constraint(equalTo: valueTextField.leftAnchor, constant: -Space.single),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: Space.single),
            
            contentView.rightAnchor.constraint(equalTo: valueTextField.rightAnchor, constant: Space.double),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor,
                                                constant: Space.single),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: iconImageView.bottomAnchor,
                                                constant: Space.single),
            
            valueTextField.leftAnchor.constraint(equalTo: subtitleLabel.rightAnchor, constant: Space.single),
            valueTextField.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
        ])
    }
    
    // MARK: - Public
    
    func setValueEditSelector(_ selector: Selector) {
        valueTextField.removeTarget(nil, action: nil, for: .editingChanged)
        valueTextField.addTarget(nil, action: selector, for: .editingChanged)
    }
    
    func setBecomeFirstResponder() {
        valueTextField.becomeFirstResponder()
    }
    
    func setResignFirstResponder() {
        valueTextField.resignFirstResponder()
    }
}

