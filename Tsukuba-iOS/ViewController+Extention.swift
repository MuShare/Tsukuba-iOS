//
//  ViewController+Extention.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 15/06/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, content: String) {
        let alertController = UIAlertController(title: title,
                                                message: content,
                                                preferredStyle: .alert)
        alertController.view.tintColor = Color.main
        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("ok_name", comment: ""), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func replaceBarButtonItemWithActivityIndicator() {
        let activityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicatorView.startAnimating()
        replaceBaeButtonItemWithView(view: activityIndicatorView)
    }
    
    func replaceBaeButtonItemWithView(view: UIView) {
        let barButton = UIBarButtonItem(customView: view)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
}
