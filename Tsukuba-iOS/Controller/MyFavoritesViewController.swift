import UIKit
import ESPullToRefresh

private let reuseIdentifier = "Cell"

class MyFavoritesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let messageManager = MessageManager.shared
    let config = Config.shared
    
    var messages: [Message] = []
    var selectedMessage: Message!
    var sell = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.contentInset = UIEdgeInsetsMake(44, 0, 49, 0)
            collectionView.scrollIndicatorInsets = collectionView.contentInset
        }
        
        // Set collection view refresh
        collectionView?.es.addPullToRefresh {
            self.messageManager.loadMyFavorites(self.sell) { (success, messages) in
                self.messages = messages
                self.collectionView?.reloadData()
                self.collectionView?.es.stopPullToRefresh()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.es.startPullToRefresh()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case R.segue.myFavoritesViewController.messageSegue.identifier:
            let destination = segue.destination as! MessageTableViewController
            destination.messageId = selectedMessage.mid
        default:
            break
        }
    }
    
}

extension MyFavoritesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / CGFloat(config.columns) - 2
        return CGSize(width: width, height: width + 50)
    }
    
}

extension MyFavoritesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.messageCell.identifier, for: indexPath) as! MessageCollectionViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
}

extension MyFavoritesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMessage = messages[indexPath.row]
        performSegue(withIdentifier: R.segue.myFavoritesViewController.messageSegue, sender: self)
    }

    
}
