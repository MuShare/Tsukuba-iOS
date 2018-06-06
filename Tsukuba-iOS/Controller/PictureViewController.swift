import UIKit
import SwiftyJSON

enum PictureViewControllerDoneType: Int {
    case dismiss = 0
    case pop = 1
    case pop2 = 2
}

class PictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    let messageManager = MessageManager.shared
    
    var mid: String!
    var doneType: PictureViewControllerDoneType = .dismiss
    var pictures: [Picture] = []
    
    var images: [UIImage] = []
    var pids: [String] = []
    var uploadingCell: PictureCollectionViewCell!
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If done type is pop, allow user to back.
        // else do not allow to back, user only can click done button to finish uploading.
        if doneType == .pop {
            self.setCustomBack()
        } else {
            self.navigationItem.hidesBackButton = true
        }
        
        imagePickerController.delegate = self
        imagePickerController.navigationBar.barTintColor = Color.main
        imagePickerController.navigationBar.tintColor = UIColor.white
        imagePickerController.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        
        messageManager.loadPictures(mid) { (success, pictures) in
            self.pictures = pictures
            self.picturesCollectionView.reloadData()
        }

    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 2
        return CGSize(width: width, height: width)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count + images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! PictureCollectionViewCell
        
        let pictureCount = pictures.count
        // If index is less than the number of existed pictures' paths, load existed pictures,
        // else load pictures from UIImagePickerController.
        if indexPath.row < pictureCount {
            cell.pictureImageView.kf.setImage(with: Config.shared.imageURL(pictures[indexPath.row].path))
            cell.removeButton.isHidden = false
        } else {
            cell.pictureImageView.image = images[indexPath.row - pictureCount]
        }
        
        if indexPath.row == pictureCount + images.count - 1 && images.count > 0 {
            cell.startLoading()
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
        
        messageManager.uploadPicture(image, mid: mid) { (success, picture) in
            if success {
                self.pids.append((picture?["pid"].stringValue)!)
                self.uploadingCell.stopLoading()
            }
        }
    }
    
    // MARK: - Action
    @IBAction func removePicture(_ sender: UIButton) {
        let cell = sender.superview?.superview as! PictureCollectionViewCell
        let indexPath = picturesCollectionView.indexPath(for: cell)!
        let picturesCount = pictures.count
        let pid = indexPath.row < picturesCount ? pictures[indexPath.row].pid : pids[indexPath.row - picturesCount]
        cell.startLoading()
        MessageManager.shared.removePicture(pid!) { (success) in
            if success {
                if indexPath.row < picturesCount {
                    self.pictures.remove(at: indexPath.row)
                } else {
                    self.images.remove(at: indexPath.row - picturesCount)
                    self.pids.remove(at: indexPath.row - picturesCount)
                }
                self.picturesCollectionView.deleteItems(at: [indexPath])
            } else {
                self.showTip(R.string.localizable.remove_picture_failed())
            }
            cell.stopLoading()
        }
    }
    
    @IBAction func uploadPicture(_ sender: Any) {
        let alertController = UIAlertController(title: R.string.localizable.upload_message_picture(),
                                                message: R.string.localizable.photo_tip(),
                                                preferredStyle: .actionSheet)
        alertController.view.tintColor = Color.main
        let takePhoto = UIAlertAction(title: R.string.localizable.photo_take(),
                                      style: .default)
        { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.cameraCaptureMode = .photo
                self.imagePickerController.cameraDevice = .rear
                self.imagePickerController.allowsEditing = true
            }
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let choosePhoto = UIAlertAction(title: R.string.localizable.photo_choose(),
                                        style: .default)
        { (action) in
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: R.string.localizable.cancel_name(),
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(takePhoto)
        alertController.addAction(choosePhoto)
        alertController.addAction(cancel)
        alertController.popoverPresentationController?.sourceView = uploadButton;
        alertController.popoverPresentationController?.sourceRect = uploadButton.bounds;
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func finishUpload(_ sender: Any) {
        switch doneType {
        case .dismiss:
            // exit modal
            self.dismiss(animated: true, completion: nil)
        case .pop:
            // Pop 1 view controller.
            self.navigationController?.popViewController(animated: true)
        case .pop2:
            // Pop 2 view controllers.
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            let destination = viewControllers[viewControllers.count - 3]
            // If go back to MessagesCollectionViewController, the collection view should be refreshed.
            if destination.isKind(of: MessagesViewController.self) {
                destination.setValue(true, forKey: "refresh")
            }
            self.navigationController!.popToViewController(destination, animated: true)
        }
    }
    
}
