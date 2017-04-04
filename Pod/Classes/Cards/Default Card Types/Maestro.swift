//
//  Maestro.swift
//  Caishen
//
//  Created by Vladyslav Lypskyi on 04/04/2017.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/**
 *  The native supported card type of Maestro
 */
public struct Maestro: CardType {
    
    public let name = "Maestro"

    public let CVCLength = 3

    public let identifyingDigits = Set([50]).union( Set(56...58) ).union( Set([6]) )

    public init() {
        
    }
    
}
