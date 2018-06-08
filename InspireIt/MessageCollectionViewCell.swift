//
//  MessageCollectionViewCell.swift
//  InspireIt
//
//  Created by Armen Avakyan on 12.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell
{
    var message: Message? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        messageTextView.text = message?.content
    }
    
    @IBOutlet weak var messageBlockWidth: NSLayoutConstraint!
    // Left and right constraints (for chat partner)
    @IBOutlet weak var messageBlockLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBlockRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageBlockView: UIView! {
        didSet {
            messageBlockView.layer.borderWidth = 2
            messageBlockView.layer.borderColor = UIColor.main.cgColor
            messageBlockView.layer.cornerRadius = 16
            messageBlockView.layer.masksToBounds = true
            messageBlockView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @IBOutlet weak var messageProfileImage: UIImageView! {
        didSet {
            messageProfileImage.makeRound()
        }
    }
    
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.font = UIFont.systemFont(ofSize: 16)
            messageTextView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
