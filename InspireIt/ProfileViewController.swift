//
//  ItemViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 27.05.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    private struct StoryBoard {
        static let editUserSegue = "Edit"
        static let changeInterestsSegue = "Change Interests"
    }
    
    var currentUser: User? {
        didSet {
            updateUI()
        }
    }
    
    // User UI
    @IBOutlet weak var userNameLabel: UILabel! { didSet { updateUI() } }
    @IBOutlet weak var userSurnameLabel: UILabel! { didSet { updateUI() } }
    @IBOutlet weak var userProfileImage: UIImageView! { didSet { updateUI() } }
    // Spinner (for photo loading)
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    // Table
    @IBOutlet weak var interestTable: UITableView!
    @IBOutlet weak var noSelectedInfoLabel: UILabel!
    // Menu burger button
    @IBOutlet weak var menuButton: UIBarButtonItem!
    // Edit button
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customizing navigation bar
        navigationController?.customize()
        
        // Side menu
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }

        // Interests
        interestTable.dataSource = self
        interestTable.delegate = self
        
        // Deleting from table view
        interestTable.allowsMultipleSelectionDuringEditing = true
        
        // Making image round
        userProfileImage.makeRound()
        
        // Edit button is active, when the photo is loaded
        editButton.isEnabled = false
        
        loadUser()
    }
    
    @IBAction func updateUserInfo(from segue: UIStoryboardSegue) {
        if let editPersonVC = segue.source as? ProfileSettingsViewController {
            // Current user was changed by reference, so just updating
            updateUI()
            userProfileImage.image = editPersonVC.profileImageView.image
        } else if segue.source is InterestsTableViewController {
            checkInterests()
            interestTable.reloadData()
        }
    }
    
    @IBAction func updateUser(from segue: UIStoryboardSegue) {
        if segue.source is LoginViewController {
            currentUser = nil
            loadUser()
        }
    }
    
    private func loadUser() {
        // Loading user
        guard let token = UserDefaults.standard.userToken else {
            presentLoginViewController()
            return
        }
        
        // Loading user
        URLSession.loadUser(byToken: token) { [weak self] loadedUser in
            DispatchQueue.main.async {
                self?.currentUser = loadedUser
            }
        }
    }
    
    private func updateUI() {
        userNameLabel?.text = currentUser?.name
        userSurnameLabel?.text = currentUser?.surname
        interestTable.reloadData()
        
        // When there is no interests selected
        checkInterests()

        spinner?.startAnimating()
        if let imageUrl = currentUser?.profileImageURL {
            userProfileImage.loadCachedImageWith(url: imageUrl) { [weak self] in
                self?.editButton.isEnabled = true
                self?.spinner?.stopAnimating()
            }
        } else {
            spinner?.stopAnimating()
        }
    }
    
    private func checkInterests() {
        noSelectedInfoLabel.text = currentUser?.interests?.count == 0 ? "No selected interests" : ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = currentUser?.interests?[indexPath.row].interest
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser?.interests?.count ?? 0
    }
    
    // For deleting
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        if let selectedInterest = currentUser?.interests?[selectedIndex] {
            if removeUserInterest(interestId: selectedInterest.id) {
                // Adding and removing
                currentUser?.interests?.remove(at: selectedIndex)
                // Reloading table
                interestTable.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    private func removeUserInterest(interestId: Int) -> Bool {
        if currentUser == nil {
            return false
        }
        
        let urlString = ApiURL.deleteInterest.rawValue
        let httpBody = "user_id=\(currentUser!.id)&interest_id=\(interestId)".data(using: .utf8)
        
        URLSession.postSession(url: urlString, requestBody: httpBody) { [weak self] (data, _, _) in
            guard let data = data else {
                print("Data error")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                let postResponse = jsonData as? [String: Bool]
                if let success = postResponse?["success"] {
                    print(success)
                    DispatchQueue.main.async {
                        self?.checkInterests()
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoard.editUserSegue {
            if let profileEditVC = segue.destination.contentViewController as? ProfileSettingsViewController {
                profileEditVC.currentUser = currentUser
                profileEditVC.userProfileImage = userProfileImage.image
            }
        } else if segue.identifier == StoryBoard.changeInterestsSegue {
            if let interestsTVC = segue.destination.contentViewController as? InterestsTableViewController {
                interestsTVC.currentUser = currentUser
            }
        }
    }
}
