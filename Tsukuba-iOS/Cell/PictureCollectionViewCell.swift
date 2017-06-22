//
//  PictureCollectionViewCell.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 09/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    func startLoading() {
        loadingActivityIndicatorView.startAnimating()
        loadingView.isHidden = false
        removeButton.isHidden = true
    }
    
    func stopLoading() {
        loadingActivityIndicatorView.stopAnimating()
        loadingView.isHidden = true
        removeButton.isHidden = false
    }
    
}
