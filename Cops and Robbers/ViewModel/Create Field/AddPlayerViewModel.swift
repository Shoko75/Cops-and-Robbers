//
//  AddPlayerViewModel.swift
//  Cops and Robbers
//
//  Created by Shoko Hashimoto on 2020-01-12.
//  Copyright © 2020 Shoko Hashimoto. All rights reserved.
//

import Foundation
import Firebase

protocol AddPlayerDelegate {
    func didFinishFetchData()
    func didFinishCheckInvitation()
}

class AddPlayerViewModel {
    
    let userInfoRef = Database.database().reference(withPath: "user_Info")
    let friendsRef = Database.database().reference(withPath: "friends")
    let invitationRef = Database.database().reference(withPath: "invitation")
    let userID = Auth.auth().currentUser?.uid

    var friendList = [Friend]()
    var playerList = [Friend]()
    var addPlayerDelegate: AddPlayerDelegate?
    var cancelPlayer = ""
    
    func fetchFriends(){
        var friendsID = [String]()
        
        friendsRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    friendsID.append(snapshot.key)
                }
            }
            self.fetchUserInfoByID(idKeys: friendsID)
        }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    func fetchUserInfoByID(idKeys: [String]){
        var frineds: [Friend] = []
        
        for idKey in idKeys {
            userInfoRef.child(idKey).observeSingleEvent(of: .value, with: { snapshot in
                
                if let friend = Friend(snapshot: snapshot) {
                    frineds.append(friend)
                }
                self.friendList = frineds
                self.addPlayerDelegate?.didFinishFetchData()
            })
        }
    }
    
    func registerInvitation() -> String {
        var players = [DBPlayer]()
        
        for player in playerList {
            let dbplayer = DBPlayer(userId: player.uid, token: player.token, status: "Waiting")
            players.append(dbplayer)
        }
        
        let game = DBInvitation(players: players, adminUser: userID!, status: "Waiting")
        
        let request = invitationRef.childByAutoId()
        request.setValue(game.toAnyObject())
        
        return request.key!
    }
    
    func updateUserPlayTeam(invitationID: String) {
        
        let invitationID = ["playTeam": invitationID]
        
        for player in playerList {
            userInfoRef.child(player.uid).updateChildValues(invitationID)
        }
    }
    
    func checkInvitation() {
        
        var cnt = 0
        cancelPlayer = ""
        
        for player in playerList {
            cnt += 1
            userInfoRef.child(player.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let value = snapshot.value as? [String: AnyObject],
                    let playTeam = value["playTeam"] as? String,
                    let userName = value["userName"] as? String {
                    
                    if playTeam != "" {
                        self.cancelPlayer = userName
                    }
                }
                if cnt == self.playerList.count {
                    self.addPlayerDelegate?.didFinishCheckInvitation()
                }
            })
        }
    }
}
