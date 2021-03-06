//
//  Game.swift
//  Cops and Robbers
//
//  Created by Shoko Hashimoto on 2020-02-01.
//  Copyright © 2020 Shoko Hashimoto. All rights reserved.
//
import Firebase

// MARK: Game
struct Game {

    let field: Field
    var cops: Cops
    var robbers: Robbers
    var flags = [Flag]()
    var admin: String
    
    init?(snapshot: DataSnapshot){
        
        guard
            let value = snapshot.value as? [String: AnyObject],
            let field = value["feild"] as? [String: AnyObject],
            let cops = value["cops"] as? [String: AnyObject],
            let robbers = value["robbers"] as? [String: AnyObject],
            let flags = value["flags"] as? [[String: AnyObject]],
            let admin = value["admin"] as? String
        else { return nil }
        
        self.field = Field(data: field)
        self.cops = Cops(data: cops)
        self.robbers = Robbers(data: robbers)
        self.admin = admin
        
        for flag in flags {
            self.flags.append(Flag(data: flag))
        }
    }
}

// MARK: Field
struct Field {
    
    let latitude: String
    let longitude: String
    
    init(data: [String: AnyObject]) {
        self.latitude = data["latitude"] as! String
        self.longitude = data["longitude"] as! String
    }
}

// MARK: Flag
struct Flag {
    let latitude: String
    let longitude: String
    let activeFlg: Bool
    
    init(data: [String: AnyObject]) {
        self.latitude = data["latitude"] as! String
        self.longitude = data["longitude"] as! String
        self.activeFlg = data["activeFlg"] as! Bool
    }
}

// MARK: Cops
struct Cops {
    let major: String
    var players: [CopPlayer]
    let points: Int
    
    init(data: [String: AnyObject]) {
        
        var cData = [CopPlayer]()
        let cPlayers = data["player"] as! [String: AnyObject]
        
        for cPlayer in cPlayers {
            let userID = cPlayer.key
            let data = cPlayer.value as! [String:AnyObject]
            
            cData.append(CopPlayer(data: data, userID: userID))
        }
        
        self.major = data["major"] as! String
        self.players = cData
        self.points = data["points"] as! Int
    }
    
    init(major: String, players: [CopPlayer], points: Int) {
        
        self.major = major
        self.points = points
        self.players = players
    }
}

// MARK: CopPlayer
struct CopPlayer {
    let userId: String
    let gameUuid: String
    var userName: String?
    var userImageURL: String?
    
    init(data: [String: AnyObject], userID: String) {
        self.userId = userID
        self.gameUuid = data["gameUuid"] as! String
        self.userName = ""
        self.userImageURL = ""
    }
}

// MARK: Robbers
struct Robbers {
    let major: String
    var robPlayers: [RobPlayer]
    let points: Int
    
    init(data: [String: AnyObject]) {
        var robs = [RobPlayer]()
        let rPlayers = data["player"] as! [String:AnyObject]
        
        for rPlayer in rPlayers {
            let userID = rPlayer.key
            let data = rPlayer.value as! [String: AnyObject]
            
            robs.append(RobPlayer(data: data, userID: userID))
        }
        
        self.robPlayers = robs
        self.major = data["major"] as! String
        self.points = data["points"] as! Int
    }
    
    init(major: String, robPlayers: [RobPlayer], points: Int) {
        self.major = major
        self.robPlayers = robPlayers
        self.points = points
    }
}

// MARK: RobPlayer
struct RobPlayer {
    let userId: String
    let gameUuid: String
    let status: RobStatus
    var userName: String?
    var userImageURL: String?
    
    init (data: [String: AnyObject], userID: String) {
        
        let strStatus = data["status"] as! String
        
        self.userId = userID
        self.gameUuid = data["gameUuid"] as! String
        self.status = RobStatus(rawValue: strStatus) ?? .Jail
        self.userName = ""
        self.userImageURL = ""
    }
}

enum RobStatus: String {
    case Alive
    case Jail
}
