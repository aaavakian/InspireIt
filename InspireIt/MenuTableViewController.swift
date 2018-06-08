//
//  MenuTableViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 27.05.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController
{
    private struct StoryBoard {
        static let dialogsSegue = "Dialogs"
        static let profileSegue = "Profile"
        static let settingsSegue = "Settings"
        static let loginSegue = "Login"
        enum cellHeight: Int {
            case picture = 120
            case row = 45
        }
    }
    
    var currentUser: User?
    
    private let menuItems: [String] = ["picture", "profile", "dialogs", "settings", "exit"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.main

        if !UserDefaults.standard.isLoggedIn {
            performSegue(withIdentifier: StoryBoard.loginSegue, sender: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let userToken = UserDefaults.standard.userToken {
            loadUser(token: userToken)
        }
    }
    
    private func loadUser(token: String) {
        URLSession.loadUser(byToken: token) { [weak self] loadedUser in
            DispatchQueue.main.async {
                self?.currentUser = loadedUser
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: menuItems[indexPath.row], for: indexPath)
        
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width/3, 0, 0)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == menuItems.startIndex {
            return CGFloat(StoryBoard.cellHeight.picture.rawValue)
        } else {
            return CGFloat(StoryBoard.cellHeight.row.rawValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == menuItems.count - 1 {
            logOut()
        }
    }
    
    func logOut() {
        // Выход из системы
        currentUser = nil
        UserDefaults.standard.setIsLoggedIn(value: false, forToken: nil)
        performSegue(withIdentifier: StoryBoard.loginSegue, sender: nil)
    }
}
