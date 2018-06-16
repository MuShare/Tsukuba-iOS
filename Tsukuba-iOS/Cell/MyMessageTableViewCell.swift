import UIKit

class MyMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var updateAtLabel: UILabel!
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    var message: Message? {
        didSet {
            guard let message = message else {
                return
            }
            titleLabel.text = message.title
            coverImageView.kf.setImage(with: Config.shared.imageURL(message.cover))
            priceLabel.text = "￥\(message.price!)"
            updateAtLabel.text = MyMessageTableViewCell.formatter.string(from: message.updateAt)
        }
    }
    
}
