//
//  Extensions.swift
//  InspireIt
//
//  Created by Armen Avakyan on 08.06.17.Extensions
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

// For image caching
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadCachedImageWith(url: URL?, completion: (()->Void)? = nil) {
        guard let url = url else {
            return
        }
        
        self.image = nil
        let key = url.absoluteString as NSString
        
        if let cachedImage = imageCache.object(forKey: key) {
            self.image = cachedImage
            DispatchQueue.main.async {
                completion?()
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        imageCache.setObject(loadedImage, forKey: key)
                        self.image = loadedImage
                        completion?()
                    }
                }
                
            }
        }
    }
}

// Authorization aspects
extension UserDefaults {
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case userToken
        case loggedUser
    }
    
    func setIsLoggedIn(value: Bool, forToken token: String?) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        set(token, forKey: UserDefaultsKeys.userToken.rawValue)
        synchronize()
    }
    
    var isLoggedIn: Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    var userToken: String? {
        return string(forKey: UserDefaultsKeys.userToken.rawValue)
    }
}

// Side menu
extension SWRevealViewController {
    func customize() {
        self.rearViewRevealWidth = 220
        self.frontViewShadowRadius = 1
        self.frontViewShadowColor = UIColor.main
        self.toggleAnimationDuration = 0.3
        self.toggleAnimationType = .easeOut
        
        // Не отъезжает вправо при выборе элемента меню
        self.rearViewRevealOverdraw = 0
        
        // Чтоб заменял (сверху накладывался)
        self.rearViewRevealDisplacement = 0
    }
}

// Colors
extension UIColor {
    static var main: UIColor {
         return UIColor(red: 55/255, green: 64/255, blue: 77/255, alpha: 1)
    }
    
    static var minor: UIColor {
        return UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
    }
}

// Image - making round
extension UIImageView {
    func makeRound(withBorder: Bool = false) {
        self.layer.borderWidth = withBorder ? 2 : 0
        self.layer.borderColor = UIColor.main.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = true
    }
}

// Navbar customize
extension UINavigationController {
    func customize() {
        navigationBar.tintColor = UIColor.main
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.main]
    }
}

extension UIViewController {
    // Content of NavigationViewController
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
    
    // From each page -> to login page
    func presentLoginViewController() {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginNavigationVC") {
            present(loginVC, animated: true, completion: nil)
        }
    }
    
    // Alert
    func alert(title: String, message: String, okTapped handlerForOkButton: ((UIAlertAction)->Void)? = nil) {
        let myAlert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        myAlert.addAction(UIAlertAction(title: "Ок", style: .default, handler: handlerForOkButton))
        present(myAlert, animated: true, completion: nil)
    }
}

extension MessagesCollectionViewController {
    func scrollToEnd() {
        if !messagesOfDialog.isEmpty {
            let indexPath = IndexPath(row: messagesOfDialog.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
}
