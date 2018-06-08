//
//  MessagesCollectionViewController.swift
//  InspireIt
//
//  Created by Armen Avakyan on 12.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Message"

// UICollectionViewDelegateFlowLayout - for custom cells
class MessagesCollectionViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
    private struct StoryBoard {
        static let UpdateDialogsSegue = "Update Dialogs"
    }
    
    var currentUser: User?

    var dialog: Dialog? {
        didSet {
            if let name = dialog?.chatPartner?.name, let surname = dialog?.chatPartner?.surname {
                title = "\(name) \(surname)"
            }
        }
    }
    
    var messagesOfDialog = [Message]() {
        didSet {
            collectionView?.reloadData()
            
            // Scroll to the last
            scrollToEnd()
        }
    }
    
    lazy var messageTextField: UITextField = {
        let textField = UITextField()
        // To regulate constraints fully
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message..."
        textField.keyboardAppearance = .dark
        textField.delegate = self
        return textField
    }()
    
    lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: UIControlState())
        button.backgroundColor = UIColor.main
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        // Tap event
        button.addTarget(self, action: #selector(handleMessageSend), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.delegate = self
        
        fetchMessagesOfDialog()
        
        // Insets - top and bottom
        // At bottom = 58, because TextField height = 50 + inset of 8
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        setInitialComponents()
        setKeyboardHandlers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // For memmory
        NotificationCenter.default.removeObserver(self)
        
        // Update dialogs
        performSegue(withIdentifier: StoryBoard.UpdateDialogsSegue, sender: nil)
    }
    
    private func setKeyboardHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // For slide
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeGesture.direction = .down
        messageTextField.addGestureRecognizer(swipeGesture)
    }
    
    var footerViewBottomAnchor: NSLayoutConstraint?
    
    // Move up on the size of the keyboard (animated)
    @objc private func handleKeyboardShow(notification: Notification) {
        // Get height
        var heightToMoveUp: CGFloat = 0
        if let keyboard = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            heightToMoveUp = keyboard.cgRectValue.height
        }
        // Get the duration
        var duration = 0.0
        if let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            duration = animationDuration
        }
        
        // Change constant than check if something was changed to animate
        footerViewBottomAnchor?.constant = -heightToMoveUp
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    // Move down to the zero
    @objc private func handleKeyboardHide(notification: Notification) {
        // Get the duration
        var duration = 0.0
        if let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            duration = animationDuration
        }
        
        footerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    // Hide keyboard when tapping
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func fetchMessagesOfDialog() {
        guard let dialogId = dialog?.id else {
            return
        }

        let urlString = ApiURL.getMessagesOf(dialog: dialogId)
        URLSession.getSession(url: urlString) { [weak self] (data, _, _) in
            guard let data = data else {
                print("Data error")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                if let arrayOfMessageDictionary = jsonData as? [[String: String]] {
                    for dictionary in arrayOfMessageDictionary {
                        if let message = self?.getMessageFrom(dictionary: dictionary) {
                            DispatchQueue.main.async {
                                self?.appendNew(message: message)
                            }
                        }
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
    }
    
    private func getMessageFrom(dictionary: [String: String]) -> Message? {
        return Message(
            id: Int(dictionary["id"] ?? ""),
            fromId: Int(dictionary["from_id"] ?? ""),
            content: dictionary["content"],
            date: dictionary["date"]
        )
    }
    
    private func appendNew(message: Message) {
        if !messagesOfDialog.contains(where: { $0.id == message.id }) {
            messagesOfDialog.append(message)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleMessageSend()
        return true
    }
    
    @objc private func handleMessageSend() {
        if let messageText = messageTextField.text, !messageText.isEmpty {
            if let newMessage = Message(fromId: currentUser?.id, content: messageText, date: Date()) {
                sendNew(message: newMessage)
            }
        }
        messageTextField.text = nil
    }
    
    private func sendNew(message: Message) {
        guard let dialogId = dialog?.id, let fromId = message.fromId, let content = message.content else {
            return
        }
        
        let urlString = ApiURL.newMessageTo(dialog: dialogId)
        let httpBody = "from_id=\(fromId)&content=\(content)".data(using: .utf8)
        
        URLSession.postSession(url: urlString, requestBody: httpBody) { [weak self] (data, _, _) in
            guard let data = data else {
                print("Data error")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                if let response = jsonData as? [String: Bool] {
                    if response["success"] ?? false {
                        DispatchQueue.main.async {
                            self?.fetchMessagesOfDialog()
                        }
                    }
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }
    }
    
    // MARK: UIScroll
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollOffset = scrollView.contentOffset.y;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        
        if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight) {
            // Update messages
            fetchMessagesOfDialog()
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return messagesOfDialog.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        if let messageCell = cell as? MessageCollectionViewCell {
            let message = messagesOfDialog[indexPath.row]
            messageCell.message = message
            
            // Configure chat patner and current user messages
            if message.isCurrentUserMessage ?? false {
                // Mine
                messageCell.messageBlockView.backgroundColor = UIColor.main
                messageCell.messageTextView.textColor = UIColor.white
                messageCell.messageProfileImage.isHidden = true
                // Constraints
                messageCell.messageBlockLeftConstraint?.isActive = false
                messageCell.messageBlockRightConstraint?.isActive = true
            } else {
                // Chat partner
                messageCell.messageBlockView.backgroundColor = UIColor.white
                messageCell.messageTextView.textColor = UIColor.main
                messageCell.messageProfileImage.isHidden = false
                // Constraints
                messageCell.messageBlockLeftConstraint?.isActive = true
                messageCell.messageBlockRightConstraint?.isActive = false
                // Image
                if let chatPartnerImageURL = dialog?.chatPartner?.profileImageURL {
                    messageCell.messageProfileImage.loadCachedImageWith(url: chatPartnerImageURL)
                }
            }
            
            // Set width
            if let messageText = message.content {
                messageCell.messageBlockWidth?.constant = getEstimatedFrame(for: messageText).width + 32
            }
            
            messageCell.layoutIfNeeded()
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // Configuring estimated message height
        if let messageText = messagesOfDialog[indexPath.row].content {
            // Plus 20 - for the textview to have padding
            height = getEstimatedFrame(for: messageText).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func getEstimatedFrame(for message: String) -> CGRect {
        // For height - something big, for width - width from the message view cell
        let size = CGSize(width: 200, height: 1000)
        // Options - how to "draw"
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        // Attributes of the string - font
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
        
        return NSString(string: message).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
}
