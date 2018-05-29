import UIKit

class UserProfileTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var createAtLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var messagesButton: UIButton!
    
    var uid: String!
    var user: User!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        UserManager.shared.get(uid) { (success, user) in
            self.user = user!
            self.loadUser()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            let destination = segue.destination as! ChatViewController
            destination.receiver = user
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - Service
    func loadUser() {
        navigationItem.title = user.name
        nameLabel.text = user.name
        if user.type == UserTypeEmail {
            emailLabel.text = user.identifier
        } else if user.type == UserTypeFacebook {
            emailLabel.text = R.string.localizable.sign_in_facebook()
        }
        avatarImageView.kf.setImage(with: imageURL(user.avatar))
        createAtLabel.text = formatter.string(from: user.createAt)
        contactLabel.text = user.contact
        addressLabel.text = user.address
    }
    
    @IBAction func sendMessages(_ sender: Any) {
        if UserManager.shared.login {
            if UserManager.shared.isCurrentUser(user!) {
                showTip(R.string.localizable.chats_self_not_allow())
            } else {
                performSegue(withIdentifier: "chatSegue", sender: self)
            }
        } else {
            showLoginAlert()
        }
    }
    
    @IBAction func reportUser(_ sender: Any) {
        let alertController = UIAlertController(title: R.string.localizable.report_user_title(),
                                                message: R.string.localizable.report_user_message(),
                                                preferredStyle: .alert)
        let report = UIAlertAction(title: R.string.localizable.report_yes(),
                                   style: .destructive)
        { (action) in
            self.showTip(R.string.localizable.report_success())
        }
        let cancel = UIAlertAction(title: R.string.localizable.cancel_name(),
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(report)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
