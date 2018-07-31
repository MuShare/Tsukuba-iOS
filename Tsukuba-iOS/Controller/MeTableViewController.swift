import UIKit
import SwiftyUserDefaults

class MeTableViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var signOutTableViewCell: UITableViewCell!
    
    let user = UserManager.shared
    var messageSell = true

    override func viewDidLoad() {
        super.viewDidLoad()
        hideFooterView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if user.login {
            updateUserInfo()
            user.pullUser(completion: { [weak self] success in
                if let `self` = self, success {
                    if (self.user.contact == "" || self.user.address == "" || self.user.avatar == "") {
                        self.showTip(R.string.localizable.fill_user_info())
                    }
                    self.updateUserInfo()
                }
            })
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // MARK: - Action
    @IBAction func logout(_ sender: Any) {
        // Sign out
        let alertController = UIAlertController(title: R.string.localizable.sign_out_title(),
                                                message: R.string.localizable.sign_out_message(),
                                                preferredStyle: .actionSheet)
        alertController.view.tintColor = .main
        let logout = UIAlertAction(title: R.string.localizable.yes_name(), style: .destructive) { action in
            self.user.logout()
            self.titleLabel.text = R.string.localizable.me_title()
            self.subtitleLabel.text = R.string.localizable.me_subtitle()
            self.avatarImageView.image = R.image.me_user()
        }
        
        let cancel = UIAlertAction(title: R.string.localizable.cancel_name(),style: .cancel)
        alertController.addAction(logout)
        alertController.addAction(cancel)
        alertController.popoverPresentationController?.sourceView = signOutTableViewCell;
        alertController.popoverPresentationController?.sourceRect = signOutTableViewCell.bounds;
        present(alertController, animated: true)
    }
    
    // MARK: - Service
    func updateUserInfo() {
        titleLabel.text = user.name
        avatarImageView.kf.setImage(with: user.avatarURL)
        switch user.type {
        case UserType.email.identifier:
            subtitleLabel.text = user.identifier
        case UserType.facebook.identifier:
            subtitleLabel.text = R.string.localizable.sign_in_facebook()
        default:
            break
        }
    }
    
}

// MARK: - UITableViewDelegate
extension MeTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if cell.reuseIdentifier == nil {
            return
        }
        switch cell.reuseIdentifier! {
        case R.reuseIdentifier.sign.identifier:
            if (user.login) {
                performSegue(withIdentifier:R.segue.meTableViewController.profileSegue, sender: self)
            } else {
                present(R.storyboard.login().instantiateInitialViewController()!, animated: true)
            }
        case R.reuseIdentifier.myMessages.identifier:
            if user.login {
                performSegue(withIdentifier: R.segue.meTableViewController.myMessagesSegue, sender: self)
            } else {
                showLoginAlert()
            }
        case R.reuseIdentifier.myFavorites.identifier:
            if user.login {
                performSegue(withIdentifier: R.segue.meTableViewController.myFavoritesSegue, sender: self)
            } else {
                showLoginAlert()
            }
        case R.reuseIdentifier.github.identifier:
            if let url = URL(string: "https://github.com/MuShare/Tsukuba-iOS") {
                UIApplication.shared.open(url, options: [:])
            }
        default:
            break
        }
    }
}
