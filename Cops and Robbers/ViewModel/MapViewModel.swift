//
//  MapViewModel.swift
//  Cops and Robbers
//
//  Created by Shoko Hashimoto on 2019-12-12.
//  Copyright © 2019 Shoko Hashimoto. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

protocol MapDelegate {
    func didFetchGame()
    func didChangeGameValues()
}

class MapViewModel {
    
    let gameRef = Database.database().reference(withPath: "game")
    let userInfoRef = Database.database().reference(withPath: "user_Info")
    let userID = Auth.auth().currentUser?.uid
    
    var enemys = [UserForGame]()
    var gameID = ""
    var flgCops: Bool?
    var gameData: Game?
    var mapDelegate: MapDelegate?
    
    func setEnemyData(gameData: Game) {
        
        if flgCops! {
            
            for enemy in gameData.robbers.robPlayers {
                
                let data = UserForGame(name: enemy.userName!, icon: enemy.userImageURL ?? "", uuid:
                    UUID(uuidString: enemy.gameUuid)!, majorValue: Int(gameData.robbers.major)!, minorValue: 1)
                enemys.append(data)
            }
            
        } else {
            for enemy in gameData.cops.players {
                
                let data = UserForGame(name: enemy.userName!, icon: enemy.userImageURL ?? "", uuid:
                    UUID(uuidString: enemy.gameUuid)!, majorValue: Int(gameData.cops.major)!, minorValue: 1)
                
                enemys.append(data)
            }
        }
    }
    
    func searchMyGameUuid(gameData: Game) -> String {
        
        let userID = Auth.auth().currentUser?.uid
        var gameUuid = ""
        
        if flgCops! {
            for player in gameData.cops.players {
                if player.userId == userID {
                    gameUuid = player.gameUuid
                }
            }
        } else {
            for player in gameData.robbers.robPlayers {
                if player.userId == userID {
                    gameUuid = player.gameUuid
                }
            }
        }
        
        return gameUuid
    }
    
    func alertForProximity(_ proximity: CLProximity,gameUuid: String) -> String {
        
        var alert = ""
        switch proximity {
        case .unknown:
            return "Unknown"
        case .immediate:

            if flgCops! {
                updateRobberStatus(gameUuid: gameUuid)
                alert = "YOU COUGHT A ROBBER!!"
            } else {
                alert = "YOU'VE BEEN SENT TO JAIL! "
            }
            return alert
            
        case .near:
            if flgCops! {
                alert = "ALERT! A ROBBER IS NEARBY!"
            } else {
                alert = "ALERT! A COP IS NEARBY!"
            }
            
            return alert
        case .far:
            if flgCops! {
                alert = "ALERT! A ROBBER IS NEARBY!"
            } else {
                alert = "ALERT! A COP IS NEARBY!"
            }
        
        return alert
        @unknown default:
        fatalError()
        }
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        
        switch proximity {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
        @unknown default:
        fatalError()
        }
    }
    
    func locationString(beacon:CLBeacon) -> String {
      //guard let beacon = beacon else { return "Location: Unknown" }
      let proximity = nameForProximity(beacon.proximity)
      let accuracy = String(format: "%.2f", beacon.accuracy)
        
      var location = " \(proximity)"
      if beacon.proximity != .unknown {
        location += " (approx. \(accuracy)m)"
      }
        
      return location
    }
    
    func updateRobberStatus(gameUuid: String) {
        
        let status = ["status": "Jail"]
        
        for player in (gameData?.robbers.robPlayers)! {
            
            if player.gameUuid == gameUuid, player.status != "Jail" {
                gameRef.child(gameID).child("robbers").child("player").child(player.userId).updateChildValues(status)
            }
        }
        
    }
    
    func observeGame() {
        gameRef.child(gameID).observe(.value) { (snapshot) in
            
            if let gameData = Game(snapshot: snapshot) {
                self.gameData = gameData
                self.fetchUserInfoByID()
                self.mapDelegate?.didChangeGameValues()
            }
        }
    }
    
    func fetchUserInfoByID() {
        var copsCnt = 0
        var robbersCnt = 0
        
        for player in (gameData?.cops.players)! {
            userInfoRef.child(player.userId).observeSingleEvent(of: .value, with: { snapshot in
                if let friend = Friend(snapshot: snapshot) {
                    self.gameData?.cops.players[copsCnt].userName = friend.userName
                    self.gameData?.cops.players[copsCnt].userImageURL = friend.userImageURL
                }
                copsCnt += 1
            })
        }
        
        for player in (gameData?.robbers.robPlayers)! {
            userInfoRef.child(player.userId).observeSingleEvent(of: .value, with: { snapshot in
                if let friend = Friend(snapshot: snapshot) {
                    self.gameData?.robbers.robPlayers[robbersCnt].userName = friend.userName
                    self.gameData?.robbers.robPlayers[robbersCnt].userImageURL = friend.userImageURL
                }
                robbersCnt += 1
                if robbersCnt == self.gameData?.robbers.robPlayers.count {
                    self.mapDelegate?.didFetchGame()
                }
            })
        }
    }
    
    func updateRobbersLabel() -> String {
        var cntJail = 0
        let total = (self.gameData?.robbers.robPlayers.count)!
        
        for player in (self.gameData?.robbers.robPlayers)! {
            if player.status == "Jail" {
                cntJail += 1
            }
        }
        
        let left = total - cntJail
        return String(left)
    }
    
    func updateFlagLabel() -> String {
        var flagCnt = 0
        if let flags = self.gameData?.flags {
            for flag in flags {
                if flag.activeFlg {
                    flagCnt += 1
                }
            }
        }
        return String(flagCnt)
    }
    
    func judgeJailStatus() -> Bool {
        if let robbers = gameData?.robbers.robPlayers {
            for robber in robbers {
                if robber.status == "Jail", robber.userId == userID {
                    return true
                }
            }
        }
        return false
    }
    
    func updateFlag(identifier: String) {
       
        let activeFlg = ["activeFlg": false]
        gameRef.child(gameID).child("flags").child(identifier).updateChildValues(activeFlg)
    }
}
