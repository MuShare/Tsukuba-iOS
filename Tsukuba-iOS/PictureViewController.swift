//
//  PictureViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 07/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import SwiftyJSON

class PictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    let message = MessageManager.sharedInstance
    
    var mid: String!
    var images: [UIImage] = []
    var pids: [String] = []
    var uploadingCell: PictureCollectionViewCell!
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        imagePickerController.delegate = self
        imagePickerController.navigationBar.barTintColor = Color.main
        imagePickerController.navigationBar.tintColor = UIColor.white
        imagePickerController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white
        ]
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 2
        return CGSize(width: width, height: width)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! PictureCollectionViewCell
        cell.pictureImageView.image = images[indexPath.row]
        if indexPath.row == images.count - 1 {
            uploadingCell = cell
        }
        return cell
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        images.append(image)
        picker.dismiss(animated: true, completion: nil)
        picturesCollectionView.reloadData()
        
        message.uploadPicture(image, mid: mid) { (success, picture) in
            if success {
                self.pids.append((picture?["pid"].stringValue)!)
                self.uploadingCell.loadingView.isHidden = true
                self.uploadingCell.removeButton.isHidden = false
            }
        }
    }
    
    // MARK: - Action
    @IBAction func removePicture(_ sender: UIButton) {
        let cell = sender.superview?.superview as! PictureCollectionViewCell
        let indexPath = picturesCollectionView.indexPath(for: cell)!
        MessageManager.sharedInstance.removePicture(pids[indexPath.row]) { (success) in
            if success {
                self.images.remove(at: indexPath.row)
                self.pids.remove(at: indexPath.row)
                self.picturesCollectionView.deleteItems(at: [indexPath])
            } else {
                showAlert(title: NSLocalizedString("Tip", comment: ""),
                          content: NSLocalizedString("remove_picture_failed", comment: ""),
                          controller: self)
            }
        }
    }
    
    
    @IBAction func uploadPicture(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("upload_message_picture", comment: ""),
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
    
    @IBAction func finishUpload(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
