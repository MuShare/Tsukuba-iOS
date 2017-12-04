//
//  MyFavoritesCollectionViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 16/06/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import ESPullToRefresh

private let reuseIdentifier = "Cell"

class MyFavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let messageManager = MessageManager.sharedInstance
    let config = Config.sharedInstance
    
    var messages: [Message] = []
    var selectedMessage: Message!
    var sell = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

}
