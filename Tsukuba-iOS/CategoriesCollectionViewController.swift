//
//  CategoriesCollectionViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Kingfisher
import DGElasticPullToRefresh

class CategoriesCollectionViewController: UICollectionViewController {
    
    let dao = DaoManager.sharedInstance
    let sync = SyncManager.sharedInstance
    var categories: [Category]!

    deinit {
        self.collectionView?.dg_removePullToRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = dao.categoryDao.findEnable()

        sync.pullCategory { (rev) in
            if rev > 0 {
                self.categories = self.dao.categoryDao.findEnable()
                self.collectionView?.reloadData()
                
                self.sync.pullSelection({ (rev) in
                    
                })
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryIdentifier",
                                                      for: indexPath) as! CategoryCollectionViewCell
        cell.nameLabel.text = category.identifier
        cell.iconImageView.kf.setImage(with: URL(string: createUrl(category.icon!)))
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: - Service
    func setDGElasticPullToRefresh () {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.lightGray
        self.collectionView?.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            SyncManager.sharedInstance.pullCategory { (success) in
                self?.categories = self?.dao.categoryDao.findEnable()
                self?.collectionView?.reloadData()
            }
        }, loadingView: loadingView)
        self.collectionView?.dg_setPullToRefreshFillColor(UIColor.red)
        self.collectionView?.dg_setPullToRefreshBackgroundColor((self.collectionView?.backgroundColor)!)
    }

}
