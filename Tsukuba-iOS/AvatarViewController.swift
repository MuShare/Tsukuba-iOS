//
//  AvatarViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Alamofire

class AvatarViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet var uploadButton: UIButton!
    
    let user = UserManager.sharedInstance
    let imagePickerController = UIImagePickerController()
    var timer: Timer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user.login {
            avatarImageView.kf.setImage(with: user.avatarURL)
        }
        
        imagePickerController.delegate = self
        imagePickerController.navigationBar.barTintColor = Color.main
        imagePickerController.navigationBar.tintColor = UIColor.white
        imagePickerController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white
        ]
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avatarImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        
        uploadButton.isEnabled = false
        self.navigationItem.hidesBackButton = true
 
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target      : self,
            selector    : #selector(updateUploadProgress),
            userInfo    : nil,
            repeats     : true)
        
        user.uploadAvatar(avatarImageView.image!) { (success) in
            self.uploadButton.isEnabled = true
            self.navigationItem.hidesBackButton = false
            self.timer?.invalidate()
            self.timer = nil
            if success {
                self.uploadButton.setTitle(NSLocalizedString("upload_profile_photo", comment: ""), for: .normal)
            }
        }
        
    }
    
    // MARK: - Action
    @IBAction func uploadAvatar(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("upload_profile_photo", comment: ""),
                                                message: NSLocalizedString("photo_tip", comment: ""),
                                                preferredStyle: .actionSheet)
        alertController.view.tintColor = Color.main
        let takePhoto = UIAlertAction(title: NSLocalizedString("photo_take", comment: ""),
                                      style: .default)
        { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.cameraCaptureMode = .photo
                self.imagePickerController.cameraDevice = .front
                self.imagePickerController.allowsEditing = true
            }
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let choosePhoto = UIAlertAction(title: NSLocalizedString("photo_choose", comment: ""),
                                        style: .default)
        { (action) in
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel_name", comment: ""),
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(takePhoto)
        alertController.addAction(choosePhoto)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Service
    func updateUploadProgress() {
        let progress = String(format: "%.2f", user.avatarUploadingProgress * 100)
        uploadButton.setTitle(NSLocalizedString("upload_progress", comment: "") + progress + "%", for: .normal)
    }
    
}
