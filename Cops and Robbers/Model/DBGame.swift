//
//  DBGame.swift
//  Cops and Robbers
//
//  Created by Shoko Hashimoto on 2020-01-20.
//  Copyright © 2020 Shoko Hashimoto. All rights reserved.
//

import Foundation

struct DBGame {
    
    let member: [Member]
    let teamStatus: TeamStatus
    
    init(member: [Member], teamStatus: TeamStatus) {
        self.member = member
        self.teamStatus = teamStatus
    }
    
    func toAnyObject() -> Any {
        
        var members = [Any]()
        for mem in member {
            members.append(mem.toAnyObject())
        }
        
        return [
            "member": members,
            "teamStatus": teamStatus.toAnyObject()
        ]
    }
}

struct Member {
    let userId: String
    let token: String
    let team: String?
    let status: String
    
    init (userId: String ,token: String, team: String, status: String) {
        self.userId = userId
        self.token = token
        self.team = team
        self.status = status
    }
    
    func toAnyObject() -> Any {
        
        return [
            "userId": userId,
            "token": token,
            "team": team,
            "status": status
        ]
    }
}

struct TeamStatus {
    let pTeamLeft: Int?
    let rTeamLeft: Int?
    
    init(pTeamLeft: Int, rTeamLeft: Int) {
        self.pTeamLeft = pTeamLeft
        self.rTeamLeft = rTeamLeft
    }
    
    func toAnyObject() -> Any {
        return [
            "pTeamLeft": pTeamLeft,
            "rTeamLeft": rTeamLeft
        ]
    }
}
