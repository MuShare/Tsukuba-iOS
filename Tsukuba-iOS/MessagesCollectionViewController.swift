//
//  MessagesCollectionViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import ESPullToRefresh


class MessagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let messageManager = MessageManager.sharedInstance
    
    var category: Category!
    var messages: [Message] = []
    var selectedMessage: Message!
    var sell = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        collectionView?.es_addPullToRefresh {
            self.messageManager.loadMessage(self.sell, cid: self.category.cid, seq: nil) { (success, messages) in
                self.messages = messages
                self.collectionView?.reloadData()
                self.collectionView?.es_stopPullToRefresh()
            }
        }
        collectionView?.es_startPullToRefresh()
    }


    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageSegue" {
            segue.destination.setValue(selectedMessage.mid, forKey: "mid")
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 3 - 2
        return CGSize(width: width, height: width * 1.4)
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
