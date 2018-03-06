import UIKit
import ESPullToRefresh

class MessageTableViewController: UITableViewController {
    
    let messageManager = MessageManager.sharedInstance
    let userManager = UserManager.sharedInstance

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
            self.messageManager.detail(self.messageId) { (success, message) in
                if (success) {
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
        if segue.identifier == "userProfileSegue" {
            segue.destination.setValue(message?.author?.uid, forKey: "uid")
        } else if segue.identifier == "chatSegue" {
            let destination = segue.destination as! ChatViewController
            destination.receiver = message?.author
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if message == nil {
            return 0
        }
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return (message?.options.count)!
        case 2:
            return 1
        case 3:
            return 1
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
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "picturesCell", for: indexPath) as! PicturesTableViewCell
            cell.fillWithMessage(message!)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! OptionTableViewCell
            cell.fillWithOption((message?.options[indexPath.row])!)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "introductionCell", for: indexPath) as! IntroductionTableViewCell
            cell.introductionLabel.text = message!.introduction
            return cell
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        default:
            return UITableViewCell()
        }        
    }

    // MARK: - Action
    @IBAction func showProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "userProfileSegue", sender: self)
    }
    
    @IBAction func reportPost(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("report_post_title", comment: ""),
                                              message: NSLocalizedString("report_post_message", comment: ""),
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
