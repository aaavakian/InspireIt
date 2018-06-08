//
//  Requests.swift
//  InspireIt
//
//  Created by Armen Avakyan on 09.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

enum ApiURL: String {
    // Index
    case index = "http://avakyan.hse.styleru.net/inspire_it/"
    // Auth
    case login = "http://avakyan.hse.styleru.net/inspire_it/login"
    case register = "http://avakyan.hse.styleru.net/inspire_it/register"
    // People
    case people = "http://avakyan.hse.styleru.net/inspire_it/people"
    case person = "http://avakyan.hse.styleru.net/inspire_it/person"
    // Adding interest to a person
    case addInterest = "http://avakyan.hse.styleru.net/inspire_it/person/interest/add"
    case deleteInterest = "http://avakyan.hse.styleru.net/inspire_it/person/interest/delete"
    // Interests
    case interests = "http://avakyan.hse.styleru.net/inspire_it/interests"
    // Make request for dialog
    case request = "http://avakyan.hse.styleru.net/inspire_it/request"
    // Dialogs
    static func getDialogsOf(person personId: Int) -> String {
        return "http://avakyan.hse.styleru.net/inspire_it/people/\(personId)/dialogs"
    }
    // Messages of the dialog
    static func getMessagesOf(dialog dialogId: Int) -> String {
        return "http://avakyan.hse.styleru.net/inspire_it/dialogs/\(dialogId)/messages"
    }
    // Add to the dialog
    static func newMessageTo(dialog dialogId: Int) -> String {
        return "http://avakyan.hse.styleru.net/inspire_it/dialogs/\(dialogId)/new_message"
    }
    // Person edit
    static func editPerson(withId id: Int) -> String {
        return "http://avakyan.hse.styleru.net/inspire_it/people/\(id)/edit"
    }
}

// GET & POST requests
extension URLSession {
    static func postSession(url: String, requestBody: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let url = URL(string: url) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = requestBody
            URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
        }
    }
    
    static func getSession(url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
        }
    }
    
    static func loadUser(byToken token: String, completionHandler: @escaping (User?) -> Void) {
        let urlString = ApiURL.person.rawValue
        let httpBody = "token=\(token)".data(using: .utf8)
        
        URLSession.postSession(url: urlString, requestBody: httpBody) { (data, resposne, error) in
            guard let data = data else {
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                let postResponse = jsonData as! [String: AnyObject]
                if postResponse["success"] as! Bool {
                    if let userDictionary = postResponse["user"] as? [String: AnyObject] {
                        var interests: [Interest]? = [Interest]()
                        if let interestsDictionary = userDictionary["interests"] as? [[String: String]] {
                            for interest in interestsDictionary {
                                if let interest = Interest(id: Int(interest["id"] ?? ""), interest: interest["interest"]) {
                                    interests?.append(interest)
                                }
                            }
                        } else {
                            interests = nil
                        }
                        let loadedUser = User(
                            id: Int(userDictionary["id"] as? String ?? ""),
                            name: userDictionary["name"] as? String,
                            surname: userDictionary["surname"] as? String,
                            login: userDictionary["login"] as? String,
                            profileImage: userDictionary["img_url"] as? String,
                            interests: interests
                        )
                        // Вызываем метод
                        completionHandler(loadedUser)
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
    }
}
