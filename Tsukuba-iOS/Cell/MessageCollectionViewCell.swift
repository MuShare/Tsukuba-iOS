import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func fillWithMessage(_ message: Message) {
        self.titleLabel.text = message.title
        self.coverImageView.kf.setImage(with: Config.shared.imageURL(message.cover))
        self.priceLabel.text = "\(message.price!)"
    }
    
}
