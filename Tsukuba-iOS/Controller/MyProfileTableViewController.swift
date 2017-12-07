import UIKit

class MyProfileTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!

    let user = UserManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBack()
        
        if user.contact == "" || user.address == "" || user.avatar == "" {
            showTip(NSLocalizedString("fill_user_info", comment: ""))
        }
        
        if user.login {
            avatarImageView.kf.setImage(with: user.avatarURL)
            nameTextField.text = user.name
            contactTextField.text = user.contact
            addressTextField.text = user.address
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if user.login {
            avatarImageView.kf.setImage(with: user.avatarURL)
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - Navigation
    @IBAction func saveUser(_ sender: Any) {
        if nameTextField.text == "" || contactTextField.text == "" || addressTextField.text == "" {
            showTip(NSLocalizedString("modify_has_empty", comment: ""))
            return
        }
        
        self.replaceBarButtonItemWithActivityIndicator()
        user.modify(name: nameTextField.text!,
                    contact: contactTextField.text!,
                    address: addressTextField.text!)
        { (success) in
            if (success) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func finishEdit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
}