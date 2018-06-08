//
//  DialogsTableViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 27.05.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class DialogsTableViewController: UITableViewController
{
    private struct StoryBoard {
        static let dialogCellIdentifier = "Dialog"
        static let newDialogSegue = "New Dialog"
        static let showDialogSegue = "Show Dialog"
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currentUser: User? {
        didSet {
            fetchDialogs()
        }
    }
    
    var dialogs = [Dialog]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func sortDialogs() {
        dialogs.sort(by: {
            if let firstDate = $0.lastMessage?.date, let secondDate = $1.lastMessage?.date {
                return firstDate > secondDate
            }
            return false
        })
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customizing navigation bar
        navigationController?.customize()
        searchBar.barTintColor = UIColor.main
        searchBar.keyboardAppearance = .dark
        
        // Side menu
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            revealViewController().customize()
        }
        
        // Adding refresher
        addRefresher()
        // Load user
        loadUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
        refreshControl?.endRefreshing()
    }
    
    @IBAction func updateUser(from segue: UIStoryboardSegue) {
        if segue.source is LoginViewController {
            loadUser()
        }
    }
    
    // Updating dialogs
    @IBAction func updateDialogs(from segue: UIStoryboardSegue) {
        if segue.source is NewDialogTableViewController {
            fetchDialogs()
        } else if let chatVC = segue.source as? MessagesCollectionViewController {
            if let dialog = chatVC.dialog {
                if let changedDialog = dialogs.first(where: { $0.id == dialog.id }) {
                    changedDialog.lastMessage = chatVC.messagesOfDialog.last
                    sortDialogs()
                }
            }
        }
    }
    
    // Add refresher
    private func addRefresher() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(fetchDialogs), for: .valueChanged)
    }
    
    // Hide keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func loadUser() {
        // Loading user
        guard let token = UserDefaults.standard.userToken else {
            presentLoginViewController()
            return
        }
        dialogs.removeAll()
        
        URLSession.loadUser(byToken: token) { [weak self] loadedUser in
            DispatchQueue.main.async {
                self?.currentUser = loadedUser
            }
        }
    }
    
    @objc private func fetchDialogs() {
        guard let userId = currentUser?.id else {
            return
        }
        
        let urlString = ApiURL.getDialogsOf(person: userId)
        URLSession.getSession(url: urlString) { [weak self] (data, resposne, error) in
            guard let data = data else {
                print("Data error")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                if let arrayOfDialogDictionary = jsonData as? [[String: AnyObject]] {
                    for dictionary in arrayOfDialogDictionary {
                        if let dialog = self?.getDialogFrom(dictionary: dictionary) {
                            DispatchQueue.main.async {
                                self?.appendNew(dialog: dialog)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self?.refreshControl?.endRefreshing()
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
    }
    
    private func getDialogFrom(dictionary: [String: AnyObject]) -> Dialog {
        let dialog = Dialog()
        if let stringId = dictionary["id"] as? String {
            dialog.id = Int(stringId)
        }
        if let firstUserDictionary = dictionary["first_user"] as? [String: String] {
            dialog.firstUser = User(
                id: Int(firstUserDictionary["id"] ?? ""),
                name: firstUserDictionary["name"],
                surname: firstUserDictionary["surname"],
                login: firstUserDictionary["login"],
                profileImage: firstUserDictionary["img_url"],
                interests: nil
            )
        }
        if let secondUserDictionary = dictionary["second_user"] as? [String: String] {
            dialog.secondUser = User(
                id: Int(secondUserDictionary["id"] ?? ""),
                name: secondUserDictionary["name"],
                surname: secondUserDictionary["surname"],
                login: secondUserDictionary["login"],
                profileImage: secondUserDictionary["img_url"],
                interests: nil
            )
        }
        if let interestDictionary = dictionary["interest"] as? [String: String] {
            dialog.interest = Interest(
                id: Int(interestDictionary["id"] ?? ""),
                interest: interestDictionary["interest"]
            )
        }
        if let lastMessageDictionary = dictionary["last_message"] as? [String: String] {
            dialog.lastMessage = Message(
                fromId: Int(lastMessageDictionary["from_id"] ?? ""),
                content: lastMessageDictionary["content"],
                date: lastMessageDictionary["date"]
            )
        }
        return dialog
    }
    
    private func appendNew(dialog: Dialog) {
        if !dialogs.contains(where: { $0.id == dialog.id }) {
            dialogs.append(dialog)
        } else {
            dialogs.first(where: { $0.id == dialog.id })!.lastMessage = dialog.lastMessage
            sortDialogs()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dialogs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.dialogCellIdentifier, for: indexPath)

        if let dialogCell = cell as? DialogTableViewCell {
            dialogCell.messageDetails = dialogs[indexPath.row].lastMessage
            dialogCell.chatPartner = dialogs[indexPath.row].chatPartner
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDialog = dialogs[indexPath.row]
        
        if let dialogCell = tableView.cellForRow(at: indexPath) as? DialogTableViewCell {
            if let image = dialogCell.userProfileImage.image {
                selectedDialog.chatPartnerImage = image
            }
        }
        
        performSegue(withIdentifier: StoryBoard.showDialogSegue, sender: dialogs[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoard.newDialogSegue {
            if let newDialogTVC = segue.destination.contentViewController as? NewDialogTableViewController {
                newDialogTVC.currentUser = currentUser
            }
        } else if segue.identifier == StoryBoard.showDialogSegue {
            if let dialog = sender as? Dialog {
                if let messagesTVC = segue.destination.contentViewController as? MessagesCollectionViewController {
                    messagesTVC.currentUser = currentUser
                    messagesTVC.dialog = dialog
                }
            }
        }
    }
}
