//
//  Copyright (c) 2020 PayMaya Philippines, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute,
//  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
//  NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import UIKit

protocol LabeledTextFieldContract: class {
    func changeValidationState(valid: Bool, defaultColor: UIColor)
    func initialSetup(data: LabeledTextFieldInitData)
}

class LabeledTextField: UIStackView {
    private var label = UILabel()
    private var textField = UITextField()
   
    #warning("make it private?")
    var model: LabeledTextFieldViewModel? {
        didSet {
            model?.setContract(self)
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.axis = .vertical
        self.distribution = .equalSpacing
        self.alignment = .leading
        self.spacing = 4.0
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LabeledTextField: LabeledTextFieldContract {
    
    func changeValidationState(valid: Bool, defaultColor: UIColor) {
        UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.label.textColor = valid ? defaultColor : .red
        })
        UIView.transition(with: textField, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.textField.textColor = valid ? defaultColor : .red
            self?.textField.layer.borderColor = valid ? defaultColor.cgColor : UIColor.red.cgColor
            self?.textField.tintColor = valid ? defaultColor : .red
        })
    }
    
    func initialSetup(data: LabeledTextFieldInitData) {
        setupViews(labelText: data.labelText, hint: data.hintText, color: data.tintColor)
    }
    
}

private extension LabeledTextField {
    
    func setupViews(labelText: String, hint: String?, color: UIColor) {
        addSubviews()
        setupLabel(text: labelText, color: color)
        setupTextField(text: labelText, hint: hint, color: color)
    }
    
    func addSubviews() {
        self.addArrangedSubview(label)
        self.addArrangedSubview(textField)
    }
    
    func setupLabel(text: String, color: UIColor) {
        label.text = text
        label.textColor = color
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    func setupTextField(text: String, hint: String?, color: UIColor) {
        textField.textColor = color
        textField.placeholder = hint ?? text
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = color.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 4.0
        textField.tintColor = color
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = model
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        guard let model = model else {return}
        textField.addTarget(model, action: #selector(LabeledTextFieldViewModel.editingDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
}