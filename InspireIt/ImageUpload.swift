//
//  RegistrationImageUpload.swift
//  InspireIt
//
//  Created by Armen Avakyan on 08.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

extension RegistrationViewController {
    func uploadImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "Choose a way to upload profile image", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { [weak self] action in
            picker.sourceType = .camera
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { [weak self] action in
            picker.sourceType = .photoLibrary
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            profileImageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileSettingsViewController {
    func uploadImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "Choose a way to upload profile image", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { [weak self] action in
            picker.sourceType = .camera
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { [weak self] action in
            picker.sourceType = .photoLibrary
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            userProfileImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
