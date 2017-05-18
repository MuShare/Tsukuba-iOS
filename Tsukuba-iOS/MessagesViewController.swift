//
//  MessagesCollectionViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import ESPullToRefresh
import Floaty
import Segmentio
import Kingfisher

class MessagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var segmentioView: Segmentio!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dao = DaoManager.sharedInstance
    let sync = SyncManager.sharedInstance
    let user = UserManager.sharedInstance
    let message = MessageManager.sharedInstance
    let config = Config.sharedInstance
    
    var categories: [Category]!
    var cid: String? = nil
    var messages: [Message] = []
    var selectedMessage: Message!
    var sell = true
    
    // Refresh flag, if this flag is true, collection view will be refreshed.
    var refresh = true
    
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
        collectionView?.es_addPullToRefresh {
            self.message.loadMessage(self.sell, cid: self.cid, seq: nil) { (success, messages) in
                self.messages = messages
                self.collectionView?.reloadData()
                self.collectionView?.es_stopPullToRefresh()
            }
        }
        
        collectionView?.es_addInfiniteScrolling {
            let seq = self.messages.last?.seq
            self.message.loadMessage(self.sell, cid: self.cid, seq: seq, completion: { (success, messages) in
                if messages.count == 0 {
                    self.collectionView?.es_noticeNoMoreData()
                } else {
                    let startRow = self.messages.count
                    self.messages = self.messages + messages
                    var indexPaths: [IndexPath] = []
                    for row in startRow...(self.messages.count - 1) {
                        indexPaths.append(IndexPath(row: row, section: 0))
                    }
                    self.collectionView?.insertItems(at: indexPaths)
                    self.collectionView?.es_stopLoadingMore()
                }
            })
        }
        
        // Set float button and menu.
        self.view.addSubview({
            let floaty = Floaty()
            floaty.buttonColor = Color.main
            floaty.plusColor = UIColor.white
            floaty.addItem("Buy Message", icon: UIImage(named: "buy")!) { item in
                self.sell = true
                self.collectionView?.es_startPullToRefresh()
            }
            floaty.addItem("Sell Message", icon: UIImage(named: "sell")!) { item in
                self.sell = false
                self.collectionView?.es_startPullToRefresh()
            }
            return floaty
        }())
    }

    override func viewWillAppear(_ animated: Bool) {
        if refresh {
            collectionView?.es_startPullToRefresh()
            refresh = false
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageSegue" {
            segue.destination.setValue(selectedMessage.mid, forKey: "messageId")
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / CGFloat(config.columns) - 2
        return CGSize(width: width, height: width + 50)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! MessageCollectionViewCell
        cell.fillWithMessage(messages[indexPath.row])
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMessage = messages[indexPath.row]
        performSegue(withIdentifier: "messageSegue", sender: self)
    }
    
    // MARK: - Action
    @IBAction func createMessage(_ sender: Any) {
        if user.login {
            performSegue(withIdentifier: "createMessageSegue", sender: self)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("tip_name", comment: ""),
                                                    message: NSLocalizedString("sign_in_before_post", comment: ""),
                                                    preferredStyle: .alert)
            alertController.view.tintColor = Color.main
            let signin = UIAlertAction(title: NSLocalizedString("sign_in_now", comment: ""),
                                       style: .destructive,
                                       handler:
            { (action) in
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            })
            let later = UIAlertAction(title: NSLocalizedString("later_name", comment: ""),
                                      style: .cancel,
                                      handler: nil)
            alertController.addAction(signin)
            alertController.addAction(later)
            present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Service
    private func loadCategories() {
        var items: [SegmentioItem] = [SegmentioItem(title: "All", image: nil)]
        for category in categories {
            items.append(SegmentioItem(title: category.identifier, image: nil))
        }
        
        segmentioView.setup(content: items, style: .onlyLabel, options: segmentioOptions())
        segmentioView.selectedSegmentioIndex = 0
        segmentioView.valueDidChange = { segmentio, segmentIndex in
            self.cid = segmentIndex == 0 ? nil : self.categories[segmentIndex - 1].cid
            self.collectionView.es_startPullToRefresh()
        }
    }
    
    private func segmentioOptions() -> SegmentioOptions {
        return SegmentioOptions(
            backgroundColor: .white,
            maxVisibleItems: 4,
            scrollEnabled: true,
            indicatorOptions: SegmentioIndicatorOptions(
                type: .bottom,
                ratio: 1,
                height: 3,
                color: Color.main
            ),
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(
                type: SegmentioHorizontalSeparatorType.topAndBottom, // Top, Bottom, TopAndBottom
                height: 1,
                color: .clear
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
                    titleTextColor: Color.main
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
