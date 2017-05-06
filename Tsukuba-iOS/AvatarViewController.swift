//
//  AvatarViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyUserDefaults

class AvatarViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet var uploadButton: UIButton!
    
    let imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePickerController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avatarImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        
        uploadButton.isEnabled = false
        self.navigationItem.hidesBackButton = true
        
        let data = UIImageJPEGRepresentation(resizeImage(image: avatarImageView.image!, newWidth: 240)!, 1.0)
        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(data!, withName: "avatar", fileName: UUID().uuidString, mimeType: "image/jpeg")
        },
                         usingThreshold: UInt64.init(),
                         to: createUrl("api/user/avatar"),
                         method: .post,
                         headers: tokenHeader(),
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.uploadProgress(closure: { (Progress) in
                                    self.uploadButton.setTitle("\(NSLocalizedString("upload_progress", comment: ""))\(Progress.fractionCompleted * 100)%", for: .normal)
                                })
                                upload.responseJSON { responseObject in
                                    let response = Response(responseObject)
                                    if response.statusOK() {
                                        let result = response.getResult()
                                        Defaults[.avatar] = result?["avatar"] as? String
                                    }
                                    
                                    self.uploadButton.setTitle(NSLocalizedString("upload_profile_photo", comment: ""), for: .normal)
                                    self.uploadButton.isEnabled = true
                                    self.navigationItem.hidesBackButton = false
                                }
                            case .failure(let encodingError):
                                debugPrint(encodingError)
                                self.uploadButton.isEnabled = true
                                self.navigationItem.hidesBackButton = false
                            }
        })
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK: - Action
    @IBAction func uploadAvatar(_ sender: Any) {
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
