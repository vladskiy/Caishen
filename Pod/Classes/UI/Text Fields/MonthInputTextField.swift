//
//  MonthInputTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/8/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/// A text field which can be used to enter months and provides validation and auto completion.
open class MonthInputTextField: DetailInputTextField {
    
    /**
     Checks the validity of the entered month.
     
     - returns: True, if the month is valid.
     */
    internal override func isInputValid(_ month: String, partiallyValid: Bool) -> Bool {
        let length = month.characters.count
        if partiallyValid && length == 0 {
            return true
        }
        
        guard let monthInt = UInt(month) else {
            return false
        }
        
        if length == 1 && !["0","1"].contains(month) {
            return false
        }
        
        return ((monthInt >= 1 && monthInt <= 12) ||
            (partiallyValid && month == "0")) &&
            (partiallyValid || length == 2)
    }

}
