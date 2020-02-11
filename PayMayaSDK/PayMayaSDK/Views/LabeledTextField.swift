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

protocol LabeledTextFieldValidityDelegate: class {
    func editingDidChange()
}

class LabeledTextField: UIStackView {
    private var label = UILabel()
    private var textField = UITextField()
   
    private weak var validityDelegate: LabeledTextFieldValidityDelegate?
    private var delegate: UITextFieldDelegate?
    private var validator: FieldValidator?
    
    private let defaultColor: UIColor
    
    var text: String {
        return (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isValid: Bool {
        guard let text = textField.text else {return false}
        return validator?.validate(string: text) ?? false
    }
    
    init(labelText: String, hint: String? = nil, tintColor: UIColor) {
        self.defaultColor = tintColor
        super.init(frame: .zero)
        self.axis = .vertical
        self.distribution = .equalSpacing
        self.alignment = .leading
        self.spacing = 4.0
        setupViews(labelText: labelText, hint: hint)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCustomDelegate(_ delegate: UITextFieldDelegate) {
        self.delegate = delegate
    }
    
    func setValidityDelegate(_ delegate: LabeledTextFieldValidityDelegate) {
        self.validityDelegate = delegate
    }
    
    func setValidator(_ validator: FieldValidator) {
        self.validator = validator
    }
}

extension LabeledTextField: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let text = textField.text, let valid = validator?.validate(string: text) else {return}
        changeValidationState(valid: valid)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.isEmpty else { return true }
        return validator?.isCharAcceptable(char: Character(string)) ?? false &&
            delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true        
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeValidationState(valid: true)
    }
    
    @objc func editingDidChange() {
        validityDelegate?.editingDidChange()
    }
}

private extension LabeledTextField {
    
    func setupViews(labelText: String, hint: String?) {
        addSubviews()
        setupLabel(text: labelText)
        setupTextField(text: labelText, hint: hint)
    }
    
    func addSubviews() {
        self.addArrangedSubview(label)
        self.addArrangedSubview(textField)
    }
    
    func setupLabel(text: String) {
        label.text = text
        label.textColor = defaultColor
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    func setupTextField(text: String, hint: String?) {
        textField.textColor = defaultColor
        textField.placeholder = hint ?? text
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = defaultColor.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 4.0
        textField.tintColor = defaultColor
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        textField.addTarget(self, action: #selector(editingDidChange), for: UIControl.Event.editingChanged)
    }
    
    func changeValidationState(valid: Bool) {
        UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.label.textColor = valid ? self?.defaultColor : .red
        })
        UIView.transition(with: textField, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.textField.textColor = valid ? self?.defaultColor : .red
            self?.textField.layer.borderColor = valid ? self?.defaultColor.cgColor : UIColor.red.cgColor
            self?.textField.tintColor = valid ? self?.defaultColor : .red
        })
    }
}
