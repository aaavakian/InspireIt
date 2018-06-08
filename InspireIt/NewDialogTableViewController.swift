//
//  NewDialogTableViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 11.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class NewDialogTableViewController: UITableViewController
{
    private struct StoryBoard {
        static let InterestCellIndentifier = "Interest"
        static let UpdateDialogsSegue = "Update Dialogs"
    }
    
    var currentUser: User? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customizing navigation bar
        navigationController?.customize()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // Close
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentUser?.interests?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.InterestCellIndentifier, for: indexPath)

        cell.textLabel?.text = currentUser?.interests?[indexPath.row].interest

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let interest = currentUser?.interests?[indexPath.row] {
            if let currentUserId = currentUser?.id {
                let urlString = ApiURL.request.rawValue
                let httpBody = "user_id=\(currentUserId)&interest_id=\(interest.id)".data(using: .utf8)
                
                URLSession.postSession(url: urlString, requestBody: httpBody) { [weak self] (data, _, _) in
                    guard let data = data else {
                        print("Data error!")
                        return
                    }
                    
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                        let postResponse = jsonData as? [String: AnyObject]
                        if let success = postResponse?["success"] as? Bool {
                            print(success)
                            if let message = postResponse?["message"] as? String, success {
                                DispatchQueue.main.async {
                                    self?.alert(title: "Success", message: message) { _ in
                                        self?.performSegue(withIdentifier: StoryBoard.UpdateDialogsSegue, sender: nil)
                                    }
                                }
                            }
                        }
                        
                    } catch let jsonError {
                        print(jsonError.localizedDescription)
                    }
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
