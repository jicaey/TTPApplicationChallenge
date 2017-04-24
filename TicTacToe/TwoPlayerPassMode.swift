//
//  TwoPlayerPassMode.swift
//  TicTacToe
//
//  Created by Michael Young on 4/23/17.
//  Copyright © 2017 Michael Young. All rights reserved.
//

import UIKit

extension MainViewController {
    
    func twoPlayerPass(_ sender: UIButton) {
        if gameState[sender.tag] == 0 && isActive {
            
            gameState[sender.tag] = player

            placeSquare(sender)
        }
        checkForWin()
    }
    
}
