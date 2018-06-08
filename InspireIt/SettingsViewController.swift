//
//  SettingsViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 27.05.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
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
    }
}
