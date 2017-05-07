//
//  PictureViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 07/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadButton: UIButton!
    
    var mid: String!
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
    }
    
    // MARK: - Action
    @IBAction func uploadPicture(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("photo_edit", comment: ""),
                                                message: NSLocalizedString("photo_tip", comment: ""),
                                                preferredStyle: .actionSheet)
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
        let cancel = UIAlertAction(title: NSLocalizedString("title", comment: ""),
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(takePhoto)
        alertController.addAction(choosePhoto)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
