//
//  UserTableViewCell.swift
//  InspireIt
//
//  Created by Armen Avakyan on 09.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class DialogTableViewCell: UITableViewCell
{
    var chatPartner: User? {
        didSet {
            updateUserUI()
        }
    }
    var messageDetails: Message? {
        didSet {
            updateMessageUI()
        }
    }
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    // Message UI
    @IBOutlet weak var messageDate: UILabel!
    @IBOutlet weak var messageContent: UILabel!
    // User UI
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView! {
        didSet {
            userProfileImage.makeRound()
        }
    }
    
    private func updateUserUI() {
        userProfileImage.image = nil
        userFullName.text = nil
        
        if let user = chatPartner {
            userFullName.text = "\(user.name) \(user.surname)"
            spinner?.startAnimating()
            if let url = user.profileImageURL {
                userProfileImage.loadCachedImageWith(url: url) { [weak self] in
                    self?.spinner?.stopAnimating()
                }
            } else {
                spinner?.stopAnimating()
            }
        }
    }
    
    private func updateMessageUI() {
        messageContent.text = nil
        messageDate.text = nil
        
        if let message = messageDetails {
            if message.isCurrentUserMessage ?? false {
                messageContent.text = "You: " + message.content!
            } else {
                messageContent.text = message.content
            }
            messageDate.text = message.formattedDate
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Place at the top
        // messageContent.sizeToFit()
    }
}
