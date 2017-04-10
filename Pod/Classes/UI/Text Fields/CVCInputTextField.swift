//
//  CVCInputTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/8/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/// A text field which can be used to enter CVCs and provides validation of the same.
open class CVCInputTextField: DetailInputTextField {
    
    /// The card type for the CVC that should be entered. The length of a CVC can vary based on this card type.
    open var cardType: CardType?

    override var expectedInputLength: Int {
        return cardType?.CVCLength ?? 3
    }
    /**
     Checks the validity of the entered card validation code.
     
     - precondition: The property `cardType` of `self` must match the card type for which a CVC should be validated.
     
     - returns: True, if the card validation code is valid.
     */
    internal override func isInputValid(_ cvcString: String, partiallyValid: Bool) -> Bool {
        let cvc = CVC(rawValue: cvcString)

        guard let _ = cvc.toInt() else {
            return false
        }

        if partiallyValid && (cvcString.characters.count <= expectedInputLength
          || cardType?.validate(cvc: cvc) == .CVCIncomplete) {
            return true
        }

        return (cardType?.validate(cvc: cvc) == .Valid)
    }

}
