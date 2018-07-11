//
//  ChatPictureTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/06/29.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit
import SnapKit
import UIImageView_Extension

protocol ChatPictureTableViewCellDelegate: class {
    func didOpenPicturePreview(url: String)
}

class ChatPictureTableViewCell: UITableViewCell {
    
    private struct Const {
        struct avatar {
            static let width: CGFloat = 40
            static let top: CGFloat = 12
            static let leading: CGFloat = 15
        }
        
        struct picture {
            static let leading: CGFloat = 63
            static let top: CGFloat = 12
        }
    }
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPicturePreview))
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.cornerRadius = 5
        return imageView
    }()
    
    private lazy var pictureImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.cornerRadius = 5
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        return activityIndicatorView
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView(frame: .zero)
        view.addSubview(loadingActivityIndicatorView)
        return view
    }()
    
    var url: String? = nil
    weak var delegate: ChatPictureTableViewCellDelegate?
    
    func fill(with url: String, size: CGSize, avatar: String, delegate: ChatPictureTableViewCellDelegate) {

        let placeholderWidth = UIScreen.main.bounds.width * 0.4
        var placeholderHeight = placeholderWidth
        if size.width > 0 && size.height > 0 {
            placeholderHeight *= size.height / size.width
        }
        let plcaeholder = UIImage(outerColor: .darkGray,
                                  innerColor: .white,
                                  size: CGSize(width: placeholderWidth, height: placeholderHeight))
        
        
        createConstraints(pictureSize: CGSize(width: placeholderWidth, height: placeholderHeight),
                          isSender: avatar == UserManager.shared.avatar)
        
        self.delegate = delegate
        self.url = url
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        
        pictureImageView.kf.indicatorType = .activity
        pictureImageView.kf.setImage(with: Config.shared.imageURL(url), placeholder: plcaeholder) { image, error, cacheType, imageURL in
            if let error = error {
                print("Loaing chat picture error: \(error)")
            }
            if let image = image {
                self.pictureImageView.image = image.resize(width: self.pictureImageView.frame.width)
            }
        }
    }
    
    func fill(with image: UIImage, avatar: String, delegate: ChatPictureTableViewCellDelegate) {
//        super.init(style: .default, reuseIdentifier: "ChatPictureTableViewCell")
        
        self.delegate = delegate
        avatarImageView.kf.setImage(with: Config.shared.imageURL(avatar))
        
        if let compressedImage = image.resize(width: pictureImageView.frame.width) {
            pictureImageView.image = compressedImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addViews()
    }
    
    private func addViews() {
        addSubview(avatarImageView)
        addSubview(pictureImageView)
        addSubview(loadingView)
    }
    
    private func createConstraints(pictureSize: CGSize, isSender: Bool) {
        
        avatarImageView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(Const.avatar.top)
            $0.width.equalTo(Const.avatar.width)
            $0.height.equalTo(Const.avatar.width)
            if isSender {
                $0.right.equalToSuperview().offset(-Const.avatar.leading)
            } else {
                $0.left.equalToSuperview().offset(Const.avatar.leading)
            }
        }
        
        pictureImageView.snp.updateConstraints {
            
            $0.top.equalTo(Const.picture.top)
            $0.bottom.equalTo(-Const.picture.top)
            $0.width.equalTo(pictureSize.width)
            $0.height.equalTo(pictureSize.height)
            if isSender {
                $0.right.equalToSuperview().offset(-Const.picture.leading)
            } else {
                $0.left.equalToSuperview().offset(Const.picture.leading)
            }
        }
        
        loadingActivityIndicatorView.snp.updateConstraints {
            $0.top.equalTo(pictureImageView.snp.top)
            $0.bottom.equalTo(pictureImageView.snp.bottom)
            $0.left.equalTo(pictureImageView.snp.left)
            $0.right.equalTo(pictureImageView.snp.right)
        }
        
    }
    
    @objc private func openPicturePreview() {
        if let delegate = delegate, let url = url {
            delegate.didOpenPicturePreview(url: url)
        }
    }
    
    func startLoading() {
        loadingView.isHidden = false
        loadingActivityIndicatorView.startAnimating()
    }
    
    func stopLoading() {
        loadingView.isHidden = true
        loadingActivityIndicatorView.stopAnimating()
    }
    
    func sendingFinished(url: String) {
        self.url = url
    }
    
}
