//
//  UserTableViewController.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController, UserCellDelegate {
    
    var manager = FeedbackManager()! // Lets just crash if we can't parse the embedded JSON
    var targetIndexPath = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueUser" {
            let userVC = segue.destination as! UserViewController
            _ = userVC.view // Access view to connect IBOutlets
            userVC.configure(with: manager.user(at: targetIndexPath)!)
        }
        
    }
    
    @IBAction func tappedRestart(_ sender: Any) {
        tableView.beginUpdates()
        tableView.deleteRows(at: manager.indexPaths, with: .right)
        manager.restart()
        tableView.insertRows(at: manager.indexPaths, with: .right)
        tableView.endUpdates()
    }
    
    // MARK: - UserCell delegate
    
    func tappedGiveFeedback(from cell: UserCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("Error: \(cell) not found in \(tableView)")
            return
        }
        
        tableView.beginUpdates()
        manager.giveFeedback(at: indexPath)
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.insertRows(at: [IndexPath(row: manager.recentFeedbackCount - 1, section: 1)], with: .right)
        tableView.endUpdates()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return manager.staleFeedbackCount
        case 1: return manager.recentFeedbackCount
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser", for: indexPath)
        let isFinalCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if
            let userCell = cell as? UserCell,
            let user = manager.user(at: indexPath)
        {
            userCell.delegate = self
            userCell.configure(for: user, isFinalCell: isFinalCell)
            return userCell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Give them some feedback"
        case 1: return "You gave them feedback recently"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserCell.height
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        targetIndexPath = indexPath
        return indexPath
    }
}
