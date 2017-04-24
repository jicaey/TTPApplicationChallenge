//
//  MainViewController.swift
//  TicTacToe
//
//  Created by Michael Young on 4/22/17.
//  Copyright © 2017 Michael Young. All rights reserved.
//

import UIKit
import CoreGraphics
import MultipeerConnectivity

class MainViewController: UIViewController {
    @IBOutlet weak var gameModeView: UIView!
    @IBOutlet weak var gameBoardView: UIView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var peersView: UIView!
    @IBOutlet weak var peersTableView: UITableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    
    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBOutlet weak var twoPlayerPassButton: UIButton!
    @IBOutlet weak var twoPlayerNetworkButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var ticLogoLabel: UILabel!
    @IBOutlet weak var tacLogoLabel: UILabel!
    @IBOutlet weak var toeLogoLabel: UILabel!
    
    var squares = [UIButton]()
    
    let gameService = GameServiceManager()
    
    let xSquare = UIImage(named: "x")
    let oSquare = UIImage(named: "o")
    
    var gameMode = String()
    var player = 1
    var isActive = true
    var aiDeciding = false
    
    var gameState = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    let winConditions = [[0, 1, 2],
                         [3, 4, 5],
                         [6, 7, 8],
                         [0, 3, 6],
                         [1, 4, 7],
                         [2, 5, 8],
                         [0, 4, 8],
                         [2, 4, 6]]
    
    var playerScore = 0
    var opponentScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameService.delegate = self
        
        setupViews()
        setupGameModeView()
        setupButtons()
        setupPeersView()
        setupLogo()
    }
    
    @IBAction func gameBoardSquareTouched(_ sender: UIButton) {
    
        switch gameMode {
        case Mode.singlePlayer:
            onePlayer(sender)
            
        case Mode.twoPlayerPass:
            twoPlayerPass(sender)
            
        case Mode.twoPlayerNetwork:
            twoPlayerNetwork(sender)
            
        default: break
        }
    }
    
    @IBAction func singlePlayerButtonTouched(_ sender: UIButton) {
        gameBoardView.alpha = 1
        gameMode = Mode.singlePlayer
        player = 1
        
        setupScoreView(for: "Player", opponent: "Computer")
        
        UIView.animate(withDuration: 0.3, animations: {
            self.gameModeView.alpha = 0
            self.statusLabel.text = "You go first"
            
            self.logoImageView.alpha = 0
            self.ticLogoLabel.alpha = 0
            self.tacLogoLabel.alpha = 0
            self.toeLogoLabel.alpha = 0
        })
        
        animateGameBoardLines()
    }
    
    @IBAction func twoPlayerPassButtonTouched(_ sender: UIButton) {
        gameBoardView.alpha = 1
        gameMode = Mode.twoPlayerPass
        
        setupScoreView(for: "X's", opponent: "O's")
        
        UIView.animate(withDuration: 0.3, animations: {
            self.gameModeView.alpha = 0
            self.statusLabel.text = "X's go first"
            
            self.logoImageView.alpha = 0
            self.ticLogoLabel.alpha = 0
            self.tacLogoLabel.alpha = 0
            self.toeLogoLabel.alpha = 0
        })
        
        animateGameBoardLines()

    }
    
    @IBAction func twoPlayerNetworkButtonTouched(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.peersView.alpha = 1
            self.gameModeView.alpha = 0
            
            self.logoImageView.alpha = 0
            self.ticLogoLabel.alpha = 0
            self.tacLogoLabel.alpha = 0
            self.toeLogoLabel.alpha = 0
        })
    }
    
    @IBAction func playAgainButtonTouched(_ sender: UIButton) {
        gameState = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        isActive = true
        playAgainButton.isHidden = true
        resetSquares()
        
        switch gameMode {
        case Mode.singlePlayer:
            player = 1
            statusLabel.text = "You go first"
        case Mode.twoPlayerPass:
            player = 1
            statusLabel.text = "X's go first"
        case Mode.twoPlayerNetwork:
            if player == 1 {
                player = 2
                statusLabel.text = "Waiting for opponent..."
                gameService.send(position: 10)
            } else {
                player = 1
                statusLabel.text = "You're up"
            }
        default: break
        }
    }
    
    @IBAction func menuButtonTouched(_ sender: UIButton) {
        quitAlert()
    }
    
    
    func setupViews() {
        scoreView.alpha = 0
        
        view.backgroundColor = Color.grey
        gameBoardView.backgroundColor = Color.grey
        
        statusLabel.font = Font.avenirULLarge
        statusLabel.textColor = Color.white
    }
    
    func setupGameModeView() {
        gameModeView.backgroundColor = Color.blue.withAlphaComponent(0.7)
        gameModeView.layer.shadowColor = UIColor.black.cgColor
        gameModeView.layer.shadowRadius = 2
        gameModeView.layer.shadowOffset = CGSize(width: 1, height: 1)
        gameModeView.layer.shadowOpacity = 0.8
        gameModeView.layer.cornerRadius = 5
    }
    
    func setupButtons() {
        playAgainButton.titleLabel?.font = Font.avenirCLarge
        playAgainButton.tintColor = Color.white
        playAgainButton.isHidden = true
        playAgainButton.setTitle("Play Again?", for: .normal)
        
        singlePlayerButton.setTitle("Single Player Mode", for: .normal)
        singlePlayerButton.titleLabel?.font = Font.avenirCLarge
        singlePlayerButton.tintColor = Color.white
        
        twoPlayerPassButton.setTitle("Two Player Pass and Play", for: .normal)
        twoPlayerPassButton.titleLabel?.font = Font.avenirCLarge
        twoPlayerPassButton.tintColor = Color.white
       
        twoPlayerNetworkButton.setTitle("Network Play - Coming Soon", for: .normal)
        twoPlayerNetworkButton.isEnabled = false
        twoPlayerNetworkButton.titleLabel?.font = Font.avenirCLarge
        twoPlayerNetworkButton.tintColor = Color.white
        
        squares = [button0,
                   button1,
                   button2,
                   button3,
                   button4,
                   button5,
                   button6,
                   button7,
                   button8]

    }
    
    func setupScoreView(for player: String, opponent: String) {
        scoreView.backgroundColor = Color.grey
        
        opponentLabel.text = opponent
        opponentScoreLabel.text = "\(opponentScore)"
        
        playerLabel.text = player
        playerScoreLabel.text = "\(playerScore)"
        
        UIView.animate(withDuration: 0.8, animations: {
            self.scoreView.alpha = 1
        })
        
    }
    
    func setupPeersView() {
        peersView.backgroundColor = Color.blue.withAlphaComponent(0.1)
        peersView.layer.shadowColor = UIColor.black.cgColor
        peersView.layer.shadowRadius = 2
        peersView.layer.shadowOffset = CGSize(width: 1, height: 1)
        peersView.layer.shadowOpacity = 0.8
        peersView.layer.cornerRadius = 5
        peersView.alpha = 0
        
        peersTableView.backgroundColor = .clear
        peersTableView.separatorStyle = .none
    }
    
    func setupLogo() {
        ticLogoLabel.alpha = 1
        tacLogoLabel.alpha = 1
        toeLogoLabel.alpha = 1
        logoImageView.alpha = 1
        
        ticLogoLabel.textColor = Color.gold
        tacLogoLabel.textColor = Color.gold
        toeLogoLabel.textColor = Color.gold
        
        let logoImage = UIImage(named: "xThin")?.withRenderingMode(.alwaysTemplate)
        logoImageView.image = logoImage
        logoImageView.tintColor = Color.purple
    }
    
    func checkForWin() {
        isActive = false
        for i in gameState {
            if i == 0 {
                isActive = true
                break
            }
        }
        
        if !isActive {
            playAgainButton.isHidden = false
            statusLabel.text = "Draw!"
        }
        
        for winCondition in winConditions {
            
            let first = gameState[winCondition[0]]
            let second = gameState[winCondition[1]]
            let third = gameState[winCondition[2]]
            
            if first != 0 && (first, second) == (second, third) {
                isActive = false
                playAgainButton.isHidden = false
                if first == 1 && gameMode == Mode.twoPlayerNetwork {
                    statusLabel.text = "You Win!"
                    updateScore(for: "player")
                    
                    playAgainButton.isHidden = false
                    
                } else if first == 1 {
                    statusLabel.text = "X Wins!"
                    updateScore(for: "player")
                    
                    playAgainButton.isHidden = false
                    
                } else if first == 2 && gameMode == Mode.twoPlayerNetwork {
                    statusLabel.text = "Aww you lost"
                    updateScore(for: "opponent")
                    
                    playAgainButton.isHidden = false
                    
                } else {
                    statusLabel.text = "O Wins!"
                    updateScore(for: "opponent")
                    
                    playAgainButton.isHidden = false
                    
                }
            }
        }
    }
    
    func updateScore(for person: String) {
        if person == "player" {
            playerScore += 1
        } else if person == "opponent" {
            opponentScore += 1
        }
        
        playerScoreLabel.text = "\(playerScore)"
        opponentScoreLabel.text = "\(opponentScore)"
    }
    
    func resetSquares() {
        for square in squares {
            square.setImage(nil, for: .normal)
        }
    }
    
    func placeSquare(_ sender: UIButton) {
        if player == 1 {
            sender.setImage(xSquare, for: .normal)
            sender.tintColor = Color.gold
            if gameMode == Mode.twoPlayerPass {
                player = 2
                self.statusLabel.text = "O's turn"
            }
        } else {
            sender.setImage(oSquare, for: .normal)
            sender.tintColor = Color.purple
            if gameMode == Mode.twoPlayerPass {
                player = 1
                self.statusLabel.text = "X's turn"
            }
        }
    }
    
    func isBoard(active: Bool) {
        for square in squares {
            if active {
                square.isUserInteractionEnabled = true
            } else {
                square.isUserInteractionEnabled = false
            }
        }
    }
    
    func animateGameBoardLines() {
        let linePath = UIBezierPath()
        
        let padding: CGFloat = 20
        let width = gameBoardView.frame.width
        let height = gameBoardView.frame.height
        
        
        // Horizontal
        linePath.move(to: CGPoint(x: -padding, y: height * 0.32))
        linePath.addLine(to: CGPoint(x: width + padding, y: height * 0.32))
        
        linePath.move(to: CGPoint(x: -padding, y: height * 0.68))
        linePath.addLine(to: CGPoint(x: width + padding, y: height * 0.68))
        
        //Vertical
        linePath.move(to: CGPoint(x: width * 0.32, y: -padding))
        linePath.addLine(to: CGPoint(x: width * 0.32, y: height + padding))
        
        linePath.move(to: CGPoint(x: width * 0.68, y: -padding))
        linePath.addLine(to: CGPoint(x: width * 0.68, y: height + padding))
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = Color.blue.cgColor
        lineLayer.lineWidth = 1
        
        gameBoardView.layer.addSublayer(lineLayer)
        
        let pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        
        lineLayer.add(pathAnimation, forKey: "strokeEnd")
        lineLayer.strokeEnd = 1.0
    }
    
    func quitAlert() {
        let alert = UIAlertController(title: "Quit", message: "Are you sure you want to quit?", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.gameState = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            self.resetSquares()
            self.playerScore = 0
            self.opponentScore = 0
            self.isActive = true
            
            UIView.animate(withDuration: 0.5, animations: {
                self.scoreView.alpha = 0
                self.gameBoardView.alpha = 0
                self.playAgainButton.isHidden = true
                self.statusLabel.text = ""
                
                self.gameModeView.alpha = 1
                
                self.logoImageView.alpha = 1
                self.ticLogoLabel.alpha = 1
                self.tacLogoLabel.alpha = 1
                self.toeLogoLabel.alpha = 1
            })

        }
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        OperationQueue.main.addOperation { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }

    }
}

extension MainViewController: MPCManagerDelegate {
    func foundPeer() {
        peersTableView.reloadData()
    }
    
    func lostPeer() {
        peersTableView.reloadData()
    }
    
    func invintationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) challenges you!.", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.gameService.invitationHandler(true, self.gameService.session)
            self.player = 2
        }
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            self.gameService.invitationHandler(false, nil)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        OperationQueue.main.addOperation { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        OperationQueue.main.addOperation { () -> Void in
            
            if self.player == 1 {
                self.isBoard(active: true)
            } else {
                self.isBoard(active: false)
            }
            
            self.gameBoardView.alpha = 1
            self.gameMode = Mode.twoPlayerNetwork
            
            self.setupScoreView(for: "Me", opponent: "Peer")
            
            UIView.animate(withDuration: 0.3, animations: {
                self.gameModeView.alpha = 0
                self.peersView.alpha = 0
                
                self.logoImageView.alpha = 0
                self.ticLogoLabel.alpha = 0
                self.tacLogoLabel.alpha = 0
                self.toeLogoLabel.alpha = 0

            })
            
            self.animateGameBoardLines()
            
            if self.player == 1 {
                self.statusLabel.text = "You go first"
            } else {
                self.statusLabel.text = "Waiting for \(peerID.displayName)"
            }
        }
    }
    
    func updateBoard(manager: GameServiceManager, position: Int) {
        OperationQueue.main.addOperation {
            for square in self.squares {
                if square.tag == position {
                    square.setImage(self.oSquare, for: .normal)
                    square.tintColor = Color.purple
                    
                    self.gameState[position] = self.player
                    self.statusLabel.text = "Your turn"
                    self.player = 1
                    self.isBoard(active: true)
                    
                    self.checkForWin()
                }
            }
        }
    }
    
    func resetBoard() {
        OperationQueue.main.addOperation {
            self.gameState = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            self.isActive = true
            self.playAgainButton.isHidden = true
            
            if self.player == 1 {
                self.player = 2
                self.statusLabel.text = "Waiting for opponent..."
            } else {
                self.player = 1
                self.statusLabel.text = "You're up"
            }

            for square in self.squares {
                square.setImage(nil, for: .normal)
            }
        }
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameService.foundPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
        cell.textLabel?.text = gameService.foundPeers[indexPath.row].displayName
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = Font.avenirMedium
        cell.textLabel?.textColor = Color.white
        cell.textLabel?.backgroundColor = .clear
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeer = gameService.foundPeers[indexPath.row] as MCPeerID
        gameService.serviceBrowser.invitePeer(selectedPeer, to: gameService.session, withContext: nil, timeout: 20)
    }
}


