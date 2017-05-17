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

class MessagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let messageManager = MessageManager.sharedInstance
    
    var category: Category!
    var messages: [Message] = []
    var selectedMessage: Message!
    var sell = true
    
    // Refresh flag, if this flag is true, collection view will be refreshed.
    var refresh = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        navigationItem.title = category.identifier
        
        // Set collection view refresh
        collectionView?.es_addPullToRefresh {
            self.messageManager.loadMessage(self.sell, cid: self.category.cid, seq: nil) { (success, messages) in
                self.messages = messages
                self.collectionView?.reloadData()
                self.collectionView?.es_stopPullToRefresh()
            }
        }
        
        collectionView?.es_addInfiniteScrolling {
            let seq = self.messages.last?.seq
            self.messageManager.loadMessage(self.sell, cid: self.category.cid, seq: seq, completion: { (success, messages) in
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

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageSegue" {
            segue.destination.setValue(selectedMessage.mid, forKey: "messageId")
        } else if segue.identifier == "createMessageSegue" {
            segue.destination.setValue(category, forKey: "category")
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 3 - 2
        return CGSize(width: width, height: width + 50)
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! MessageCollectionViewCell
        cell.fillWithMessage(messages[indexPath.row])
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMessage = messages[indexPath.row]
        self.performSegue(withIdentifier: "messageSegue", sender: self)
    }
    
}
