import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var message: Message? {
        didSet {
            guard let message = message else {
                return
            }
            titleLabel.text = message.title
            coverImageView.kf.setImage(with: Config.shared.imageURL(message.cover))
            priceLabel.text = "\(message.price!)"
        }
    }
    
}
