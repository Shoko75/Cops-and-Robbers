//
//  WaitingPlayerAdminViewController.swift
//  Cops and Robbers
//
//  Created by Shoko Hashimoto on 2020-01-24.
//  Copyright © 2020 Shoko Hashimoto. All rights reserved.
//

import UIKit
import Firebase

class WaitingPlayerAdminViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var customView: CustomUIView!
    
    fileprivate var waitingPlayerViewModel: WaitingPlayerViewModel!
    var invitationID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layout setting
        startButton.layer.cornerRadius = 12
        cancelButton.layer.cornerRadius = 12
        
        // initial setting
        startButton.isEnabled = false
        
        waitingPlayerViewModel = WaitingPlayerViewModel()
        waitingPlayerViewModel.waitingPlayerDelegate = self
        
        guard let invitationID = invitationID else { return }
        waitingPlayerViewModel.invitationID = invitationID
        
        waitingPlayerViewModel.observeInvitation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        customView.roundCorners(cornerRadius: 50.0)
    }
    
    func controlStartButton(){
        let countPlayers = waitingPlayerViewModel.playerList.count
        var cntAnswer = 0
        var cntJoin = 0
        
        for player in waitingPlayerViewModel.playerList {
            if player.status != "Waiting" {
                cntAnswer += 1
                
                if player.status == "Joined" {
                    cntJoin += 1
                }
                
                if countPlayers == cntAnswer, cntJoin >= 1 {
                    startButton.isEnabled = true
                    startButton.backgroundColor = UIColor.systemOrange
                    startButton.setTitleColor(UIColor.white, for: .normal)
                    waitingPlayerViewModel.stopObserveInvitation()
                }
            }
        }
    }

    @IBAction func pressedCancell(_ sender: Any) {
        waitingPlayerViewModel.deleteInvitation()
        self.navigationController?.popToRootViewController(animated: false)
    }
    @IBAction func pressedStart(_ sender: Any) {
        waitingPlayerViewModel.createPassData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showLoadGame" {
            if let loadGameViewController = segue.destination as? LoadGameViewController {
                loadGameViewController.passedData = waitingPlayerViewModel.playerList
                loadGameViewController.flgAdmin = true
                loadGameViewController.gameID = invitationID
            }
        }
    }
}

// MARK: UITableViewDelegate
extension WaitingPlayerAdminViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waitingPlayerViewModel.playerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WaitingPlayerAdminTableCell", for: indexPath) as! WaitingPlayerAdminTableViewCell
        let values = waitingPlayerViewModel.playerList[indexPath.row]
        cell.setCellValues(cellValues: values)
        return cell
    }
}

extension WaitingPlayerAdminViewController: WaitingPlayerDelegate {
    func didStartGame() {
        print("didStartGame")
    }
    
    func didCancleInvitation() {
        print("didCancleInvitation")
    }
    
    func didCreatePassData() {
        self.performSegue(withIdentifier: "showLoadGame", sender: nil)
    }
    
    func didfetchData() {
        self.tableView.reloadData()
        self.controlStartButton()
    }
}
