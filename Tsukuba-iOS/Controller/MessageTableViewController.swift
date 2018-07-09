import UIKit
import ESPullToRefresh

class MessageTableViewController: UITableViewController {
    
    let messageManager = MessageManager.shared
    let userManager = UserManager.shared

    var messageId: String!
    var message: Message? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setCustomBack()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.contentInset = UIEdgeInsetsMake(UIApplication.shared.statusBarFrame.size.height + 44, 0, 49, 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        tableView.es.addPullToRefresh {
            self.messageManager.detail(self.messageId) { [weak self] (success, message) in
                if let `self` = self, success {
                    self.message = message!
                    self.navigationItem.title = message!.title
                    self.tableView.reloadData()
                    self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)

                    if !self.userManager.isCurrentUser(message!.author!) {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                }
            }
        }
        tableView.es.startPullToRefresh()

    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case R.segue.messageTableViewController.userProfileSegue.identifier:
            let destination = segue.destination as! UserProfileViewController
            destination.uid = message?.author?.uid
        default:
            break
        }
    }

    // MARK: - Action
    @IBAction func showProfile(_ sender: Any) {
        self.performSegue(withIdentifier: R.segue.messageTableViewController.userProfileSegue, sender: self)
    }
    
    @IBAction func chat(_ sender: Any) {
        if userManager.login {
            if let chatViewController = R.storyboard.chat.chatViewController() {
                chatViewController.receiver = message?.author
                navigationController?.pushViewController(chatViewController, animated: true)
            }
        } else {
            showLoginAlert()
        }
    }
    
    @IBAction func reportPost(_ sender: Any) {
        let alertController = UIAlertController(title: R.string.localizable.report_post_title(),
                                              message: R.string.localizable.report_post_message(),
                                       preferredStyle: .alert)
        let report = UIAlertAction(title: R.string.localizable.report_yes(), style: .destructive) { action in
            self.showTip(R.string.localizable.report_success())
        }
        let cancel = UIAlertAction(title: R.string.localizable.cancel_name(), style: .cancel)
        alertController.addAction(report)
        alertController.addAction(cancel)
        self.present(alertController, animated: true)
    }
    
}

// MARK: - Table view data source
extension MessageTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if message == nil {
            return 0
        }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2, 3:
            return 1
        case 1:
            return (message?.options.count)!
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if message == nil {
            return 0
        }
        switch indexPath.section {
        case 0:
            return UIScreen.main.bounds.size.width + 45
        case 1, 2, 3:
            return UITableViewAutomaticDimension
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = message else {
            return UITableViewCell()
        }
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.picturesCell.identifier, for: indexPath) as! PicturesTableViewCell
            cell.message = message
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionCell.identifier, for: indexPath) as! OptionTableViewCell
            cell.option = message.options[indexPath.row]
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.introductionCell.identifier, for: indexPath) as! IntroductionTableViewCell
            cell.introductionLabel.text = message.introduction
            return cell
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.reportCell.identifier, for: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
}
