//
//  CategoriesCollectionViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Kingfisher
import ESPullToRefresh

class CategoriesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let dao = DaoManager.sharedInstance
    let sync = SyncManager.sharedInstance

    var categories: [Category]!

    override func viewDidLoad() {
        super.viewDidLoad()
        categories = dao.categoryDao.findEnable()
        
        collectionView?.es_addPullToRefresh {
            // Refresh action
            self.sync.pullCategory { (rev, update) in
                // Stop refreshing.
                self.collectionView?.es_stopPullToRefresh()
                if rev > 0 {
                    if update {
                        self.categories = self.dao.categoryDao.findEnable()
                        self.collectionView?.reloadData()
                        
                    }
                    self.sync.pullSelection({ (rev, update) in
                        if rev > 0 {
                            self.sync.pullOption(nil)
                        }
                    })
                }
            }
        }
        // Start refresh
        collectionView?.es_startPullToRefresh()
    }

    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 3
        return CGSize(width: width, height: width * 1.17)
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

}
