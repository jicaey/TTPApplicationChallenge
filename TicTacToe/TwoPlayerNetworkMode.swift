//
//  TwoPlayerNetworkMode.swift
//  TicTacToe
//
//  Created by Michael Young on 4/23/17.
//  Copyright © 2017 Michael Young. All rights reserved.
//

import UIKit

extension MainViewController {
    func twoPlayerNetwork(_ sender: UIButton){
        if player == 1 {
            
            if gameState[sender.tag] == 0 && isActive {
                sender.setImage(xSquare, for: .normal)
                sender.tintColor = Color.gold
                
                gameState[sender.tag] = player
                gameService.send(position: sender.tag)
                
                statusLabel.text = "Waiting for Opponent"
                player = 2
                isBoard(active: false)
                checkForWin()
            }
        }
    }
}
