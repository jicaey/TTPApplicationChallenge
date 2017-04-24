//
//  Constants.swift
//  TicTacToe
//
//  Created by Michael Young on 4/22/17.
//  Copyright © 2017 Michael Young. All rights reserved.
//

import UIKit

struct Color {
    static let gold = UIColor(red: 0.95, green: 0.73, blue: 0.00, alpha: 1.0)
    static let purple = UIColor(red: 0.38, green: 0.15, blue: 0.23, alpha: 1.0)
    static let grey = UIColor(red: 0.13, green: 0.15, blue: 0.16, alpha: 1.0)
    static let white = UIColor(red: 0.97, green: 0.98, blue: 0.96, alpha: 1.0)
    static let blue = UIColor(red: 0.09, green: 0.40, blue: 0.55, alpha: 1.0)
}

struct Font {
    static let avenirLarge = UIFont(name: "Avenir Next", size: 25)
    static let avenirMedium = UIFont(name: "Avenir Next", size: 20)
    static let avenirSmall = UIFont(name: "Avenir Next", size: 16)
    
    static let avenirULLarge = UIFont(name: "AvenirNextCondensed-UltraLight", size: 30)
    static let avenirULMedium = UIFont(name: "AvenirNextCondensed-UltraLight", size: 20)
    static let avenirULSmall = UIFont(name: "AvenirNextCondensed-UltraLight", size: 16)
    
    static let avenirCLarge = UIFont(name: "Avenir Next Condensed", size: 25)
    static let avenirCMedium = UIFont(name: "Avenir Next Condensed", size: 20)
    static let avenirCSmall = UIFont(name: "Avenir Next Condensed", size: 16)
}

struct Mode {
    static let singlePlayer = "Single Player Mode"
    static let twoPlayerPass = "Two Player Pass and Play"
    static let twoPlayerNetwork = "Two Player Network Mode"
}

