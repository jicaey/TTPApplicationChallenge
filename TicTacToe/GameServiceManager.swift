//
//  GameServiceManager.swift
//  TicTacToe
//
//  Created by Michael Young on 4/23/17.
//  Copyright © 2017 Michael Young. All rights reserved.
//

import MultipeerConnectivity

protocol MPCManagerDelegate {
    func foundPeer()
    func lostPeer()
    func invintationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)
    func updateBoard(manager: GameServiceManager, position: Int)
    func resetBoard()
}

class GameServiceManager: NSObject {
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession?) -> Void)!
    var delegate: MPCManagerDelegate?
    
    private let gameServiceType = "player-move"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    let serviceBrowser: MCNearbyServiceBrowser
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: gameServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: gameServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    func send(position: Int) {
        NSLog("%@", "sendPosition: \(position) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                let positionString = "\(position)"
                try self.session.send(positionString.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
}

extension GameServiceManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        self.invitationHandler = invitationHandler
        delegate?.invintationWasReceived(fromPeer: peerID.displayName)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
}

extension GameServiceManager : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        
        foundPeers.append(peerID)
        delegate?.foundPeer()
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        
        for (index, aPeer) in foundPeers.enumerated() {
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
        delegate?.lostPeer()
    }
    
}

extension GameServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        
        switch state {
        case MCSessionState.connected:
            print("*******************************Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID: peerID)
        case MCSessionState.connecting:
            print("*******************************Connecting to session: \(session)")
        default:
            print("*******************************Did not connect to session: \(session)")
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        
        let str = String(data: data, encoding: .utf8)!
        let position = Int(str)
        
        if let code = position {
            if code == 10 {
                self.delegate?.resetBoard()
            } else {
               self.delegate?.updateBoard(manager: self, position: code)
            }
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}

