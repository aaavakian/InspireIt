//
//  InterestsTableViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 19.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class InterestsTableViewController: UITableViewController
{
    private struct StoryBoard {
        static let interestCell = "Interest"
        static let changeInterestsSegue = "Change Interests"
    }
    
    var currentUser: User?
    
    private var interests = [Interest]() {
        didSet {
            interests.sort { $0.interest < $1.interest }
            
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchInterests()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Update interests
        performSegue(withIdentifier: StoryBoard.changeInterestsSegue, sender: nil)
    }

    private func fetchInterests() {
        let urlString = ApiURL.interests.rawValue
        URLSession.getSession(url: urlString) { [weak self] (data, resposne, error) in
            guard let data = data else {
                print("Data error")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                if let arrayOfInterests = jsonData as? [[String: String]] {
                    for dictionary in arrayOfInterests {
                        let interest = Interest(
                            id: Int(dictionary["id"] ?? ""),
                            interest: dictionary["interest"]
                        )
                        if interest != nil {
                            DispatchQueue.main.async {
                                self?.interests.append(interest!)
                            }
                        }
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return interests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.interestCell, for: indexPath)

        let interest = interests[indexPath.row]
        cell.textLabel?.text = interest.interest
        
        // If checked
        if currentUser?.interests?.contains(where: { $0.id == interest.id }) ?? false {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == UITableViewCellAccessoryType.none {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                addUserInterest(atIndex: indexPath.row)
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
                removeUserInterest(atIndex: indexPath.row)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func addUserInterest(atIndex index: Int) {
        if currentUser == nil {
            return
        }
        
        // Get selected interest
        let selectedInterest = interests[index]
        
        let urlString = ApiURL.addInterest.rawValue
        let httpBody = "user_id=\(currentUser!.id)&interest_id=\(selectedInterest.id)".data(using: .utf8)
        
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
                    // Adding
                    DispatchQueue.main.async {
                        self?.currentUser?.interests?.append(selectedInterest)
                        // Reloading
                        self?.tableView.reloadData()
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
    }
    
    private func removeUserInterest(atIndex index: Int) {
        if currentUser == nil {
            return
        }
        
        // Get selected interest
        let selectedInterest = interests[index]
        
        let urlString = ApiURL.deleteInterest.rawValue
        let httpBody = "user_id=\(currentUser!.id)&interest_id=\(selectedInterest.id)".data(using: .utf8)
        
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
                        self?.removeInterest(withId: selectedInterest.id)
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
    }
    
    private func removeInterest(withId id: Int) {
        // Removing
        currentUser?.interests = currentUser?.interests?.filter { $0.id != id }
        tableView.reloadData()
    }
}
