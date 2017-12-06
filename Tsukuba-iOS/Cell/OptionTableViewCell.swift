import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionLaebl: UILabel!
    @IBOutlet weak var optionLabel: UILabel!
    
    func fillWithOption(_ option: Option) {
        selectionLaebl.text = option.selection?.name
        optionLabel.text = option.name
    }

}
