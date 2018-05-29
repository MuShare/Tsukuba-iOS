import UIKit

class MyProfileTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBack()
        
        let user = UserManager.shared
        if user.contact == "" || user.address == "" || user.avatar == "" {
            showTip(R.string.localizable.fill_user_info())
        }
        
        if UserManager.shared.login {
            avatarImageView.kf.setImage(with: user.avatarURL)
            nameTextField.text = user.name
            contactTextField.text = user.contact
            addressTextField.text = user.address
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserManager.shared.login {
            avatarImageView.kf.setImage(with: UserManager.shared.avatarURL)
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - Navigation
    @IBAction func saveUser(_ sender: Any) {
        if nameTextField.text == "" || contactTextField.text == "" || addressTextField.text == "" {
            showTip(R.string.localizable.modify_has_empty())
            return
        }
        
        self.replaceBarButtonItemWithActivityIndicator()
        UserManager.shared.modify(name: nameTextField.text!,
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
