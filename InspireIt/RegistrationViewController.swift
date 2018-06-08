//
//  RegistrationViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 27.05.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.tag = 1; nameTextField.autocorrectionType = .no } }
    @IBOutlet weak var surnameTextField: UITextField! { didSet { surnameTextField.tag = 2; surnameTextField.autocorrectionType = .no } }
    @IBOutlet weak var loginTextField: UITextField! { didSet { loginTextField.tag = 3; loginTextField.autocorrectionType = .no } }
    @IBOutlet weak var passwordTextField: UITextField! { didSet { passwordTextField.tag = 4 } }
    @IBOutlet weak var repeatPasswordTextField: UITextField! { didSet { repeatPasswordTextField.tag = 5 } }
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customizing navigation bar
        navigationController?.customize()

        // Delegates
        nameTextField.delegate = self
        surnameTextField.delegate = self
        loginTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        
        // Tap gesture
        profileImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(uploadImage))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // Making circle
        profileImageView.makeRound(withBorder: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Unfocus
        loginTextField.resignFirstResponder()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        saveChanges()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let currentTag = textField.tag
        
        if currentTag < 5 {
            if let nextTextField = view.viewWithTag(currentTag + 1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        } else {
            saveChanges()
        }
        
        return false
    }
    
    func saveChanges() {
        if nameTextField.text?.isEmpty ?? true {
            alert(title: "Empty entry", message: "Enter your name!") { [weak self] action in
                self?.nameTextField.becomeFirstResponder()
            }
            return
        } else if surnameTextField.text?.isEmpty ?? true {
            alert(title: "Empty entry", message: "Enter your surname!") { [weak self] action in
                self?.surnameTextField.becomeFirstResponder()
            }
            return
        } else if loginTextField.text?.isEmpty ?? true {
            alert(title: "Empty entry", message: "Enter login!") { [weak self] action in
                self?.loginTextField.becomeFirstResponder()
            }
            return
        } else if passwordTextField.text?.isEmpty ?? true {
            alert(title: "Empty entry", message: "Enter your password!") { [weak self] action in
                self?.passwordTextField.becomeFirstResponder()
            }
            return
        } else if repeatPasswordTextField.text?.isEmpty ?? true {
            alert(title: "Empty entry", message: "Repeat your password!") { [weak self] action in
                self?.repeatPasswordTextField.becomeFirstResponder()
            }
            return
        } else {
            if let pwd1 = passwordTextField.text, let pwd2 = repeatPasswordTextField.text {
                if pwd1 != pwd2 {
                    alert(title: "Error!", message: "Passwords do not match!") { [weak self] action in
                        self?.repeatPasswordTextField.becomeFirstResponder()
                    }
                    return
                }
            } else {
                alert(title: "Error!", message: "Try one more time.")
                return
            }
        }
        
        register()
    }
    
    func register() {
        spinner?.startAnimating()
            
        checkNewUser(
            name: nameTextField.text!,
            surname: surnameTextField.text!,
            login: loginTextField.text!,
            password: passwordTextField.text!
        )
    }
    
    func checkNewUser(name: String, surname: String, login: String, password: String) {
        let urlString = ApiURL.register.rawValue
        let httpBody = "name=\(name)&surname=\(surname)&login=\(login)&pwd=\(password)"
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
                        _ = self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.spinner?.stopAnimating()
                        self?.alert(title: "Error!", message: "Login is already in use.")
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
        // Get image data
        let imageData = UIImagePNGRepresentation(profileImageView.image!)
        if let base64 = imageData?.base64EncodedString() {
            body += "&img=\(base64)"
        }
        return body.data(using: .utf8)
    }
}
