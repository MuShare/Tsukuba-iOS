import UIKit
import ESPullToRefresh

class MyMessagesTableViewController: UITableViewController {
    
    var sell = true
    
    let user = UserManager.shared
    let messageManager = MessageManager.shared
    var messages: [Message] = []
    var selectedMessage: Message!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.contentInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.size.height + 44, left: 0, bottom: 49, right: 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
        }
        
        tableView.es.addPullToRefresh {
            self.messageManager.loadMyMessage(self.sell) { (success, messages) in
                self.messages = messages
                self.tableView.reloadData()
                self.tableView.es.stopPullToRefresh()
            }
        }
        tableView.es.startPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if messageManager.updated {
            tableView.es.startPullToRefresh()
            messageManager.updated = false
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case R.segue.myMessagesTableViewController.editMessageSegue.identifier:
            let destination = segue.destination as! EditMessageViewController
            destination.messageId = selectedMessage.mid
        default:
            break
        }
    }

    // MARK: - Action
    @IBAction func createMessage(_ sender: Any) {
        if user.login {
            present(R.storyboard.post().instantiateInitialViewController()!, animated: true)
        } else {
            showLoginAlert()
        }
    }
    
    /**
    @IBAction func changeMessageType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sell = true
        case 1:
            sell = false
        default:
            break
        }
        tableView.es_startPullToRefresh()
    }
    */
    
}

extension MyMessagesTableViewController {
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let identifier = message.enable ? R.reuseIdentifier.myMessageCell.identifier: R.reuseIdentifier.closedMessageCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MyMessageTableViewCell
        cell.message = message
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMessage = messages[indexPath.row]
        if selectedMessage.enable {
            self.performSegue(withIdentifier: R.segue.myMessagesTableViewController.editMessageSegue, sender: self)
        }
    }
    
}
