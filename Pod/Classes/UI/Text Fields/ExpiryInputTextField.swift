//
//  ExpiryInputTextField.swift
//  Caishen
//
//  Created by Vladyslav Lypskyi on 31/03/2017.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

public protocol ExpiryTextFieldDelegate {
    
    func textField(_ textField: ExpiryInputTextField, didEnterValidInfo: (month: String, year: String))
    
    func textField(_ textField: ExpiryInputTextField, didEnterPartiallyValidInfo: (month: String, year: String))
}

open class ExpiryInputTextField: FloatingLabelTextField {
    
    open var expiryTextFieldDelegate: ExpiryTextFieldDelegate?
    
    /**
     The string that is used to separate month and year.
     */
    @IBInspectable
    open var expirySeparator: String = "/"
    
    fileprivate var _expirySeparator: Character {
        return expirySeparator.characters.first ?? "/"
    }
    
    open var cardInfoTextFieldDelegate: CardInfoTextFieldDelegate?
    
    open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text ?? ""
        let newText = NSString(string: oldText).replacingCharacters(in: range, with: string)
        
        let deletedLastCharacter = !oldText.isEmpty && newText.isEmpty
        if deletedLastCharacter {
            textField.text = newText
            expiryTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: ("", ""))
            return false
        }
        
        let unformattedOld = parse(oldText)
        let unformattedNew = parse(newText)

        let deletedSeparator = unformattedOld.containsSeparator && !unformattedNew.containsSeparator
        if deletedSeparator {
            var month = unformattedOld.month
            let year = unformattedOld.year
            guard !month.isEmpty else {
                // Do nothing
                return false
            }
            month = month.substring(to: month.index(before: month.endIndex))
            textField.text = format(month: month, year: year)
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: month.characters.count) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            expiryTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: (month, year))
            return false
        }
        
        // Do not autocomplete if user deletes rather than inserts
        let shouldAutocomplete = unformattedNew.month.characters.count > unformattedOld.month.characters.count
        let month = shouldAutocomplete ? autocomplete(unformattedNew.month) : unformattedNew.month
        let year = unformattedNew.year

        if isInputValid(month: month, year: year, partiallyValid: true) {
            let deletedCharacter = newText.characters.count < oldText.characters.count
            let monthEntered = month.characters.count == 2 && month.characters.count > unformattedOld.month.characters.count
            var offset = deletedCharacter ? -1 : 1
            var cursorPosition: Int? = nil
            if let selectedRange = textField.selectedTextRange {
                cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            }
            textField.text = format(month: month, year: year)
            if monthEntered == false,
                let cursorPosition = cursorPosition,
                let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorPosition + offset) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            if isInputValid(month: month, year: year, partiallyValid: false) {
                expiryTextFieldDelegate?.textField(self, didEnterValidInfo: (month, year))
            } else {
                expiryTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: (month, year))
            }
        }
        
        return false
    }

    open func prefill(_ text: String) {
        // TODO
    }
    
    open func format(month: String, year: String) -> String {
        if !year.isEmpty || month.characters.count == 2 {
            return month + expirySeparator + year
        } else {
            return month
        }
    }
    
    open func parse(_ text: String) -> (month: String, year: String, containsSeparator: Bool) {
        guard let index = text.characters.index(of: _expirySeparator) else {
            return (text, "", false)
        }
        let month = text.substring(to: index)
        let year = text.substring(from: text.index(after: index))
        return (month, year, true)
    }
    
    fileprivate func autocomplete(_ month: String) -> String {
        let length = month.characters.count
        guard length == 1 else {
            // Does not require completion
            return month
        }

        let monthNumber = Int(month) ?? 0
        if monthNumber > 1 {
            return "0" + month
        }

        return month
    }
    
    open func isInputValid(month: String, year: String, partiallyValid: Bool) -> Bool {
        return isMonthValid(month, partiallyValid: partiallyValid) && isYearValid(year, partiallyValid: partiallyValid)
    }
    
    fileprivate func isMonthValid(_ month: String, partiallyValid: Bool) -> Bool {
        let length = month.characters.count
        guard length <= 2 else {
            return false
        }
        
        if partiallyValid && length == 0 {
            return true
        }
        
        guard let monthInt = UInt(month) else {
            return false
        }
        
        return ((monthInt >= 1 && monthInt <= 12) ||
            (partiallyValid && month == "0")) &&
            (partiallyValid || length == 2)
    }
    
    fileprivate func isYearValid(_ year: String, partiallyValid: Bool) -> Bool {
        let length = year.characters.count
        guard length <= 2 else {
            return false
        }
        
        if partiallyValid && length == 0 {
            return true
        }
        
        guard let yearInt = UInt(year) else {
            return false
        }
        
        return yearInt >= 0 &&
            yearInt < 100 &&
            (partiallyValid || length == 2)
    }
  
}
