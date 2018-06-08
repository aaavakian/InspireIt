//
//  TextFieldForDialog.swift
//  InspireIt
//
//  Created by Armen Avakyan on 12.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

extension MessagesCollectionViewController
{
    func setInitialComponents() {
        // Main block with textfield, send button - footer
        let footerView = UIView()
        footerView.backgroundColor = UIColor.white
        footerView.translatesAutoresizingMaskIntoConstraints = false
        // Adding to the view
        view.addSubview(footerView)
        // Making it to be at the bottom with height = 50 and view width
        footerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        footerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        footerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        // Take the bottom anchor
        footerViewBottomAnchor = footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        footerViewBottomAnchor?.isActive = true
        
        // Send message button
        footerView.addSubview(sendMessageButton)
        // Constraints - at the right part of footer with height of 80
        sendMessageButton.rightAnchor.constraint(equalTo: footerView.rightAnchor).isActive = true
        sendMessageButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
        sendMessageButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendMessageButton.heightAnchor.constraint(equalTo: footerView.heightAnchor).isActive = true
        
        // Text field
        footerView.addSubview(messageTextField)
        // Constraints - at the left part of the footer
        messageTextField.leftAnchor.constraint(equalTo: footerView.leftAnchor, constant: 8).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
        messageTextField.rightAnchor.constraint(equalTo: sendMessageButton.leftAnchor).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: footerView.heightAnchor).isActive = true
        
        // Separator
        let separator = UIView()
        separator.backgroundColor = UIColor.main
        separator.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(separator)
        // Constraints - at the top of the view with height of 1
        separator.leftAnchor.constraint(equalTo: footerView.leftAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: footerView.widthAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
