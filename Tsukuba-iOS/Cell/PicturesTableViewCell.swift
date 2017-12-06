import UIKit
import ImageSlideshow
import FaveButton

class PicturesTableViewCell: UITableViewCell {

    @IBOutlet weak var picturesImageSlideshow: ImageSlideshow!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var updateAtLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favoriteButton: FaveButton!
    @IBOutlet weak var favoritesLabel: UILabel!
    
    var message: Message!
    let messageManager = MessageManager.sharedInstance
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    func fillWithMessage(_ message: Message) {
        self.message = message
        load()
    }
    
    private func load() {
        // Slide view
        var inputs: [InputSource] = []
        for picture in message.pictures {
            inputs.append(KingfisherSource(urlString: createUrl(picture.path))!)
        }
        // If message does not contain any picture, set a input using default cover.
        if inputs.count == 0 {
            inputs.append(KingfisherSource(urlString: createUrl(message.cover))!)
        }
        picturesImageSlideshow.setImageInputs(inputs)
        
        // Author info
        avatarImageView.kf.setImage(with: imageURL((message.author?.avatar)!))
        nameButton.setTitle(message.author?.name, for: .normal)
        updateAtLabel.text = formatter.string(from: message.updateAt)
        priceLabel.text = "￥\(message.price!)"
        
        favoritesLabel.text = "\(message.favorites!)"
        print(message.favorite)
        favoriteButton.isSelected = message.favorite
    }
    
    @IBAction func favoriteMessage(_ sender: Any) {
        if !UserManager.sharedInstance.login {
            self.parentViewController?.showLoginAlert()
        }
        
        if favoriteButton.isSelected {
            messageManager.like(message.mid, completion: { (success, favorites, tip) in
                if success {
                    self.favoritesLabel.text = "\(favorites)"
                } else {
                    self.favoriteButton.isSelected = false
                }
            })
        } else {
            messageManager.unlike(message.mid, completion: { (success, favorites, tip) in
                if success {
                    self.favoritesLabel.text = "\(favorites)"
                } else {
                    self.favoriteButton.isSelected = true
                }
            })
        }
    }

}
