//
//  ViewController.swift
//  Caishen
//
//  Created by Daniel Vancura on 02/03/2016.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit
import Caishen

class ViewController: UIViewController, CardTextFieldDelegate, CardIOPaymentViewControllerDelegate {
    
    @IBOutlet weak var buyButton: UIBarButtonItem?
    @IBOutlet weak var cardNumberTextField: CardTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buyButton?.enabled = false
        cardNumberTextField.cardTextFieldDelegate = self
    }
    
    @IBAction func buy(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - CardNumberTextField delegate methods
    
    // This method of `CardNumberTextFieldDelegate` will set the saveButton enabled or disabled, based on whether valid card information has been entered.
    func cardTextField(cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {
            buyButton?.enabled = validationResult == .Valid
    }
    
    func cardTextFieldShouldShowAccessoryImage(cardTextField: CardTextField) -> UIImage? {
        return UIImage(named: "camera")
    }
    
    func cardTextFieldShouldProvideAccessoryAction(cardTextField: CardTextField) -> (() -> ())? {
        return { [weak self] _ in
            let cardIOViewController = CardIOPaymentViewController(paymentDelegate: self)
            self?.presentViewController(cardIOViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Card.io delegate methods
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        cardNumberTextField.prefillCardInformation(cardInfo.cardNumber, month: Int(cardInfo.expiryMonth), year: Int(cardInfo.expiryYear), cvc: cardInfo.cvv)
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }

}

