import UIKit

class UserProfileTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var createAtLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    let userManager = UserManager.sharedInstance
    
    var uid: String!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        userManager.get(uid) { (success, user) in
            self.loadUser(user!)
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - Service
    func loadUser(_ user: User) {
        navigationItem.title = user.name
        nameLabel.text = user.name
        if user.type == UserTypeEmail {
            emailLabel.text = user.identifier
        } else if user.type == UserTypeFacebook {
            emailLabel.text = NSLocalizedString("sign_in_facebook", comment: "")
        }
        avatarImageView.kf.setImage(with: imageURL(user.avatar))
        createAtLabel.text = formatter.string(from: user.createAt)
        contactLabel.text = user.contact
        addressLabel.text = user.address
    }
    
    @IBAction func sendMessages(_ sender: Any) {
        if userManager.login {
            present(UIStoryboard(name: "Message", bundle: nil).instantiateInitialViewController()!,
                    animated: true, completion: nil)
        } else {
            showLoginAlert()
        }
    }
    
    @IBAction func reportUser(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("report_user_title", comment: ""),
                                                message: NSLocalizedString("report_user_message", comment: ""),
                                                preferredStyle: .alert)
        let report = UIAlertAction(title: NSLocalizedString("report_yes", comment: ""),
                                   style: .destructive)
        { (action) in
            self.showTip(NSLocalizedString("report_success", comment: ""))
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel_name", comment: ""),
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(report)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
