//
//  OnePlayerMode.swift
//  TicTacToe
//
//  Created by Michael Young on 4/22/17.
//  Copyright © 2017 Michael Young. All rights reserved.
//

import UIKit

extension MainViewController {
    
    func onePlayer(_ sender: UIButton) {
        print("sender: \(sender.tag), isActive: \(isActive), aiDeciding: \(aiDeciding)")
        
        if gameState[sender.tag] == 0 && isActive && !aiDeciding {
            
            gameState[sender.tag] = player
            statusLabel.text = "The Computer is thinking..."
            checkForWin()
            aiTurn(sender)
            placeSquare(sender)
        }
    }
    
    func aiTurn(_ sender: UIButton) {
        aiDeciding = true
        var delay: Double = 2
        
        for i in gameState {
            if i != 0 {
                delay -= 0.2
            }
        }
        
        let corners = [self.button0, self.button2, self.button6, self.button8]
        let sides = [self.button1, self.button3, self.button5, self.button7]
        var availableSquares = [UIButton]()
        
        if !self.isActive {
            aiDeciding = false
            return
        }
        
        // Does the Computer have two in a row
        delayWithSeconds(delay) {
            if let moveLocation = self.checkRow(of: "computer") {
                for square in self.squares {
                    if square.tag == moveLocation {
                        square.setImage(self.oSquare, for: .normal)
                        square.tintColor = Color.purple
                        self.gameState[moveLocation] = 2
                        self.statusLabel.text = "Now you go"
                        self.checkForWin()
                        self.aiDeciding = false
                        return
                    }
                }
            }
            
            //  Does the Player have two in a row
            if let moveLocation = self.checkRow(of: "player") {
                for square in self.squares {
                    if square.tag == moveLocation {
                        square.setImage(self.oSquare, for: .normal)
                        square.tintColor = Color.purple
                        self.gameState[moveLocation] = 2
                        self.statusLabel.text = "Your turn"
                        self.checkForWin()
                        self.aiDeciding = false
                        return
                    }
                }
            }
            
            // Is the Center available
            if self.gameState[4] == 0 {
                self.button4.setImage(self.oSquare, for: .normal)
                self.button4.tintColor = Color.purple
                self.gameState[4] = 2
                self.statusLabel.text = "You're up"
                self.checkForWin()
                self.aiDeciding = false
                return
            }
            
            // Is a Corner available
            for corner in corners {
                if let index = corner?.tag {
                    if self.gameState[index] == 0 {
                        availableSquares.append(corner!)
                    }
                }
            }
            
            // Is a Side available
            if availableSquares.isEmpty {
                for side in sides {
                    if let index = side?.tag {
                        if self.gameState[index] == 0 {
                            availableSquares.append(side!)
                        }
                    }
                }
            }
            
            let randomIndex = Int(arc4random_uniform(UInt32(availableSquares.count)))
            let randomSquare = availableSquares[randomIndex]
            randomSquare.setImage(self.oSquare, for: .normal)
            randomSquare.tintColor = Color.purple
            self.gameState[randomSquare.tag] = 2
            self.statusLabel.text = "Now you go"
            self.aiDeciding = false
            self.checkForWin()
        }
        return
    }
    
    func checkRow(of: String) -> Int? {
        var acceptablePatterns = [[Int]]()

        if of == "player" {
            acceptablePatterns = [[1, 1, 0], [1, 0, 1], [0, 1, 1]]
        } else {
            acceptablePatterns = [[2, 2, 0], [2, 0, 2], [0, 2, 2]]
        }
        
        var result: Int? = nil
        
        for winCondition in winConditions {
            let first = gameState[winCondition[0]]
            let second = gameState[winCondition[1]]
            let third = gameState[winCondition[2]]
            
            let state = [first, second, third]
            
            for pattern in acceptablePatterns {
                if state == pattern {
                    
                    for (index, value) in state.enumerated() {
                        if value == 0 {
                            result = winCondition[index]
                        }
                    }
                    break
                }
            }
        }
        
        return result
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
