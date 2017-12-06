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
    
    func fillWithMessage(_ message: Message) {
        self.titleLabel.text = message.title
        self.coverImageView.kf.setImage(with: imageURL(message.cover))
        self.priceLabel.text = "￥\(message.price!)"
        self.updateAtLabel.text = MyMessageTableViewCell.formatter.string(from: message.updateAt)
    }

}
