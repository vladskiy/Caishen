//
//  DetailInputTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 A text field subclass that validates any input for card detail before changing the text attribute.
 You can subclass `DetailInputTextField` and override `isInputValid` to specify the validation routine.
 The default implementation accepts any input.
 */
open class DetailInputTextField: FloatingLabelTextField {
    
    open var cardInfoTextFieldDelegate: CardInfoTextFieldDelegate?
    
    open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text ?? ""
        let newText = NSString(string: oldText).replacingCharacters(in: range, with: string)
        
        let deletingLastCharacter = !oldText.isEmpty && newText.isEmpty
        if deletingLastCharacter {
            textField.text = newText
            cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: newText)
            return false
        }
        
        if isInputValid(newText, partiallyValid: true) {
            let deletedCharacter = newText.characters.count < oldText.characters.count
            let offset = deletedCharacter ? -1 : 1
            var cursorPosition: Int? = nil
            if let selectedRange = textField.selectedTextRange {
                cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            }
            textField.text = newText
            if let cursorPosition = cursorPosition,
                let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorPosition + offset) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            if isInputValid(newText, partiallyValid: false) {
                cardInfoTextFieldDelegate?.textField(self, didEnterValidInfo: newText)
            } else {
                cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: newText)
            }
        }
        
        return false
    }
    
    open func prefill(_ text: String) {
        if isInputValid(text, partiallyValid: false) {
            self.text = text
            cardInfoTextFieldDelegate?.textField(self, didEnterValidInfo: text)
        } else if isInputValid(text, partiallyValid: true) {
            self.text = text
            cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: text)
        }
    }
    
}

extension DetailInputTextField: TextFieldValidation {
    /**
     Default number of expected digits for MonthInputTextField and YearInputTextField
     */
    var expectedInputLength: Int {
        return 2
    }

    func isInputValid(_ input: String, partiallyValid: Bool) -> Bool {
        return true
    }
}
