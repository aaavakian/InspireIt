//
//  ProfileSettingsViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 02.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private struct StoryBoard {
        static let editProfileSegue = "Edit Profile"
    }
    
    var currentUser: User?
    
    private var photoWasChanged: Bool = false

    var userProfileImage: UIImage? {
        didSet {
            if profileImageView != nil {
                photoWasChanged = true
                profileImageView.image = userProfileImage
            }
        }
    }

    @IBOutlet weak var profileImageView: UIImageView! { didSet { profileImageView.image = userProfileImage } }
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.tag = 1 } }
    @IBOutlet weak var surnameTextField: UITextField! { didSet { surnameTextField.tag = 2 } }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private func updateUI() {
        nameTextField.text = currentUser?.name
        surnameTextField.text = currentUser?.surname
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        // Customizing navigation bar
        navigationController?.customize()
        
        // Delegates
        nameTextField.delegate = self
        surnameTextField.delegate = self
        nameTextField.autocorrectionType = .no
        surnameTextField.autocorrectionType = .no
        // Focus
        nameTextField.becomeFirstResponder()
        
        // Tap gesture
        profileImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(uploadImage))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // Making circle
        profileImageView.makeRound()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            surnameTextField.becomeFirstResponder()
        } else {
            saveChanges()
        }
        
        return true
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        saveChanges()
    }
    
    private func saveChanges() {
        if let currentUserId = currentUser?.id {
            if let name = nameTextField.text, let surname = surnameTextField.text {
                spinner?.startAnimating()
                
                currentUser?.name = name
                currentUser?.surname = surname
                
                saveChangesForUser(
                    withId: currentUserId,
                    name: name,
                    surname: surname
                )
            }
        }
    }
    
    private func saveChangesForUser(withId id: Int, name: String, surname: String) {
        let urlString = ApiURL.editPerson(withId: id)
        let httpBody = "name=\(name)&surname=\(surname)"
        let httpData = getPostBody(postString: httpBody)
        
        URLSession.postSession(url: urlString, requestBody: httpData) { [weak self] (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {
                print("Data error")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                let postResponse = jsonData as! [String: AnyObject]
                print(postResponse)
                if postResponse["success"] as! Bool {
                    DispatchQueue.main.async {
                        self?.spinner?.stopAnimating()
                        self?.performSegue(withIdentifier: StoryBoard.editProfileSegue, sender: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.spinner?.stopAnimating()
                        self?.alert(title: "Error!", message: "Something went wrong.")
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
                DispatchQueue.main.async {
                    self?.spinner?.stopAnimating()
                }
                return
            }
        }
    }
    
    func getPostBody(postString: String) -> Data? {
        var body = postString
        
        if photoWasChanged {
            // Get image data
            let imageData = UIImagePNGRepresentation(profileImageView.image!)
            if let base64 = imageData?.base64EncodedString() {
                body += "&img=\(base64)"
            }
        }
        
        return body.data(using: .utf8)
    }
}
