//
//  ViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 11.05.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate
{
    private struct StoryBoard {
        static let loginTag = 1
        static let passwordTag = 2
        static var firstTag: Int {
            return loginTag
        }
        static let loginSegue = "Login"
        static let registerSegue = "Register"
        static let updateUserSegue = "Update User"
    }
    
    @IBOutlet weak var loginTextField: UITextField! { didSet { loginTextField.tag = StoryBoard.loginTag } }
    @IBOutlet weak var passwordTextField: UITextField! { didSet { passwordTextField.tag = StoryBoard.passwordTag } }
    @IBOutlet weak var logInButton: UIBarButtonItem!
    
    var login: String?
    {
        get { return loginTextField.text }
        set { loginTextField.text = newValue }
    }
    var password: String?
    {
        get { return passwordTextField.text }
        set { passwordTextField.text = newValue }
    }
    var error: Bool {
        if login != nil, password != nil {
            return login!.isEmpty || password!.isEmpty
        }
        return true
    }

    @IBAction func logInButtonTapped(_ sender: UIBarButtonItem) {
        logIn()
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customizing navigation bar
        navigationController?.customize()
        
        logInButton.isEnabled = false
        // Text change event
        loginTextField.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
        // Delegate
        loginTextField.delegate = self
        loginTextField.autocorrectionType = .no
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Clear
        logInButton.isEnabled = false
        loginTextField.text = ""
        passwordTextField.text = ""
        spinner?.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Focus
        loginTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Unfocus
        loginTextField.resignFirstResponder()
    }
    
    func textChange(_ textField: UITextField) {
        logInButton.isEnabled = !error
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let currentTag = textField.tag
        
        if currentTag == StoryBoard.firstTag {
            if let nextTextField = view.viewWithTag(currentTag + 1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        } else {
            logIn()
        }
        
        return false
    }
    
    private func logIn() {
        if !error {
            spinner?.startAnimating()
            checkUser(by: login!, withPassword: password!)
        }
    }
    
    private var loggedUser: User?
    
    private func checkUser(by login: String, withPassword password: String) {
        let urlString = ApiURL.login.rawValue
        let httpBody = "login=\(login)&pwd=\(password)".data(using: .utf8)
        
        URLSession.postSession(url: urlString, requestBody: httpBody) { [weak self] (data, resposne, error) in
            guard let data = data else {
                print("Data error")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                let postResponse = jsonData as! [String: AnyObject]
                if postResponse["success"] as! Bool {
                    DispatchQueue.main.async {
                        self?.spinner?.stopAnimating()
                        if let token = postResponse["token"] as? String {
                            // Save information about entering the system
                            UserDefaults.standard.setIsLoggedIn(value: true, forToken: token)
                            self?.performSegue(withIdentifier: StoryBoard.updateUserSegue, sender: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.spinner?.stopAnimating()
                        self?.alert(title: "Error", message: "Incorrect login or password!")
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
    }
}
