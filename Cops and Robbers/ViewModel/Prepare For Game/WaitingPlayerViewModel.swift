//
//  WaitingPlayerViewModel.swift
//  Cops and Robbers
//
//  Created by Shoko Hashimoto on 2020-01-24.
//  Copyright © 2020 Shoko Hashimoto. All rights reserved.
//
import Firebase

// MARK: Protocol
protocol WaitingPlayerDelegate {
    func didfetchData()
    func didCreatePassData()
    func didCancleInvitation()
    func didStartGame()
}

// MARK: WaitingPlayerViewModel
class WaitingPlayerViewModel {
    
    let invitationRef = Database.database().reference(withPath: "invitation")
    let userInfoRef = Database.database().reference(withPath: "user_Info")
    let userID = Auth.auth().currentUser?.uid
    
    var playerList = [Player]()
    var waitingPlayerDelegate: WaitingPlayerDelegate?
    var invitationID: String?
    
    // MARK: Observing
    func observeInvitation() {
        invitationRef.child(invitationID!).observe(.value) { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject],
                let members = value["player"] as? [String: AnyObject],
                let status = value["status"] as? String {
                var players = [Player]()
                var dummyFriend: Friend?
                
                if status == "Start" {
                    self.waitingPlayerDelegate?.didStartGame()
                } else {
                
                    for member in members.keys {
                        if let value = members[member] as? [String:AnyObject],
                            let status = value["status"] as? String,
                            let invitationStatus = InvitationStatus(rawValue: status) {
                            players.append(Player(playerID: member, status: invitationStatus, user: dummyFriend))
                        }
                    }
                    self.fetchUserInfoByID(players: players)
                }
                
            }
        }
    }
    
    func observeUserInfo() {
        userInfoRef.child(userID!).observe(.value) { (snapshot) in
            
            if let value = snapshot.value as? [String: AnyObject],
                let playTeam = value["playTeam"] as? String {
                
                if playTeam == "" {
                    self.waitingPlayerDelegate?.didCancleInvitation()
                }
            }
        }
    }
    
    func stopObserveInvitation() {
        invitationRef.child(invitationID!).removeAllObservers()
    }
    
    func stopObserveUserInfo() {
        userInfoRef.child(userID!).removeAllObservers()
    }
    
    // MARK: Fetch
    func fetchUserInfoByID(players: [Player]) {
        var temPlayer: [Player] = []
        var cnt = 0
        
        for player in players {
            userInfoRef.child(player.playerID).observeSingleEvent(of: .value, with: { snapshot in
                cnt += 1
                if let friend = Friend(snapshot: snapshot) {
                    temPlayer.append(Player(playerID: player.playerID, status: player.status, user: friend))
                }
                if cnt == players.count {
                    self.playerList = temPlayer
                    self.waitingPlayerDelegate?.didfetchData()
                }
            })
        }
    }
    
    func fetchAdminUserInfo() {
        
        userInfoRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            if let friend = Friend(snapshot: snapshot) {
                let adminUser = Player(playerID: friend.uid, status: .Joined, user: friend)
                self.updateInvitationPlayer(updateInfo: adminUser)
                self.playerList.append(adminUser)
                self.updateInvitationStatus()
                self.waitingPlayerDelegate?.didCreatePassData()
            }
        })
    }
    
    // MARK: Registration
    func createPassData(){
        var joinedPlayers = [Player]()
        
        for player in playerList {
            
            switch player.status {
                case .Joined:
                    joinedPlayers.append(player)
                case .Declined:
                    let request = invitationRef.child(invitationID!).child("player").child(player.playerID)
                    request.removeValue()
                case .Waiting: print("Waiting")
            }
        }
        self.playerList = joinedPlayers
        fetchAdminUserInfo()
    }
    
    // MARK: Update
    func updateInvitationPlayer(updateInfo: Player) {
       
        let adminData = DBPlayer(userId: updateInfo.playerID, token: updateInfo.user!.token, status: updateInfo.status.rawValue)
        
        let request = invitationRef.child(invitationID!).child("player").child(adminData.userId)
        request.setValue(adminData.toAnyObject())
        
    }
    
    func updateInvitationStatus(){
        
        let request = invitationRef.child(invitationID!).child("status")
        request.setValue("Start")
    }
    
    func deleteInvitation(){
        // Invitation
        invitationRef.child(invitationID!).removeValue()
        
        let playTeamValue = ["playTeam": ""]
        
        // User
        for player in playerList {
            userInfoRef.child(player.user!.uid).updateChildValues(playTeamValue)
        }
        
        userInfoRef.child(userID!).updateChildValues(playTeamValue)
    }
    
    func declineInvitation() {
        let updateStatus = ["status": InvitationStatus.Declined.rawValue]
        invitationRef.child(invitationID!).child("player").child(userID!).updateChildValues(updateStatus)
    
        let playTeamValue = ["playTeam": ""]
        userInfoRef.child(userID!).updateChildValues(playTeamValue)
        
    }
    
    func joinInvitation() {
        let updateStatus = ["status": InvitationStatus.Joined.rawValue]
        invitationRef.child(invitationID!).child("player").child(userID!).updateChildValues(updateStatus)
    }
}
