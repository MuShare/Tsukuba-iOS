import UIKit
import ESPullToRefresh
import Segmentio

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var segmentioView: Segmentio!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nodataImageView: UIImageView!
    @IBOutlet weak var nodataLabel: UILabel!
    
    let dao = DaoManager.shared
    let sync = SyncManager.shared
    let user = UserManager.shared
    let messageManager = MessageManager.shared
    let config = Config.shared
    
    var categories: [Category]!
    var cid: String? = nil
    var messages: [Message] = []
    var selectedMessage: Message!
    var sell = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = dao.categoryDao.findEnable()
        loadCategories()
        
        // Refresh categories, selections and options.
        self.sync.pullCategory { (rev, update) in
            if rev > 0 {
                if update {
                    self.categories = self.dao.categoryDao.findEnable()
                    self.loadCategories()
                }
                self.sync.pullSelection({ (rev, update) in
                    if rev > 0 {
                        self.sync.pullOption(nil)
                    }
                })
            }
        }
        
        // Set collection view refresh
        collectionView?.es.addPullToRefresh {
            self.messageManager.loadMessage(self.sell, cid: self.cid, seq: nil) { (success, messages) in
                // Show no data tip if there is no message.
                if (messages.count == 0) {
                    self.nodataLabel.isHidden = false
                    self.nodataImageView.isHidden = false
                } else {
                    self.nodataLabel.isHidden = true
                    self.nodataImageView.isHidden = true
                }
                // Update messages.
                self.messages = messages
                self.collectionView?.reloadData()
                self.collectionView?.es.stopPullToRefresh()
            }
        }
        collectionView?.es.startPullToRefresh()
        
        collectionView?.es.addInfiniteScrolling {
            let seq = self.messages.last?.seq
            self.messageManager.loadMessage(self.sell, cid: self.cid, seq: seq, completion: { (success, messages) in
                if messages.count == 0 {
                    self.collectionView?.es.noticeNoMoreData()
                } else {
                    let startRow = self.messages.count
                    self.messages = self.messages + messages
                    var indexPaths: [IndexPath] = []
                    for row in startRow...(self.messages.count - 1) {
                        indexPaths.append(IndexPath(row: row, section: 0))
                    }
                    self.collectionView?.insertItems(at: indexPaths)
                    self.collectionView?.es.stopLoadingMore()
                }
            })
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if messageManager.updated {
            collectionView?.es.startPullToRefresh()
            messageManager.updated = false
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case R.segue.messagesViewController.messageSegue.identifier:
            let destination = segue.destination as! MessageTableViewController
            destination.messageId = selectedMessage.mid
        default:
            break
        }
    }

    // MARK: - Service
    func createMessage() {
        if user.login {
            present(R.storyboard.post().instantiateInitialViewController()!, animated: true, completion: nil)
        } else {
            showLoginAlert()
        }
    }
    
    private func loadCategories() {
        var items: [SegmentioItem] = [SegmentioItem(title: R.string.localizable.message_all(),
                                                    image: nil)]
        for category in categories {
            items.append(SegmentioItem(title: category.name, image: nil))
        }
        
        segmentioView.setup(content: items, style: .onlyLabel, options: segmentioOptions())
        segmentioView.selectedSegmentioIndex = 0
        segmentioView.valueDidChange = { segmentio, segmentIndex in
            self.cid = segmentIndex == 0 ? nil : self.categories[segmentIndex - 1].cid
            self.collectionView.es.startPullToRefresh()
        }
    }
    
    private func segmentioOptions() -> SegmentioOptions {
        return SegmentioOptions(
            backgroundColor: .white,
            segmentPosition: .fixed(maxVisibleItems: config.columns),
            scrollEnabled: true,
            indicatorOptions: SegmentioIndicatorOptions(
                type: .bottom,
                ratio: 1,
                height: 4,
                color: .main
            ),
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(
                type: SegmentioHorizontalSeparatorType.bottom, // Top, Bottom, TopAndBottom
                height: 0,
                color: .main
            ),
            verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(
                ratio: 0.6, // from 0.1 to 1
                color: .clear
            ),
            imageContentMode: .center,
            labelTextAlignment: .center,
            labelTextNumberOfLines: 1,
            segmentStates: SegmentioStates(
                defaultState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                    titleTextColor: .black
                ),
                selectedState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                    titleTextColor: .main
                ),
                highlightedState: SegmentioState(
                    backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                    titleFont: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
                    titleTextColor: .black
                )
            ),
            animationDuration: 0.1
        )
    }
    
}

extension MessagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / CGFloat(config.columns) - 2
        return CGSize(width: width, height: width + 50)
    }
    
}

extension MessagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! MessageCollectionViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
}

extension MessagesViewController: UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMessage = messages[indexPath.row]
        performSegue(withIdentifier: R.segue.messagesViewController.messageSegue, sender: self)
    }
    
}
