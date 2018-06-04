//
//  CustomBack.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 11/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setCustomBack() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(closeView))
        self.navigationController?.swipeBackEnabled = true
    }
    
    @objc func closeView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func hideFooterView(for tableView: UITableView) {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView?.backgroundColor = UIColor.clear
    }

    func showTip(_ tip: String) {
        showAlert(title: R.string.localizable.tip_name(),
                  content: tip)
    }
    
    func showAlert(title: String, content: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: title,
                                                    message: content,
                                                    preferredStyle: .alert)
            alertController.view.tintColor = Color.main
            alertController.addAction(UIAlertAction.init(title: R.string.localizable.ok_name(), style: .cancel))
            self?.present(alertController, animated: true)
        }
        
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
    
    func showLoginAlert() {
        let alertController = UIAlertController(title: R.string.localizable.tip_name(),
                                                message: R.string.localizable.sign_in_at_first(),
                                                preferredStyle: .alert)
        alertController.view.tintColor = Color.main
        let signin = UIAlertAction(title: R.string.localizable.sign_in_now(),
                                   style: .destructive,
                                   handler:
            { (action) in
                self.present(UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!,
                             animated: true, completion: nil)
        })
        let later = UIAlertAction(title: R.string.localizable.later_name(),
                                  style: .cancel,
                                  handler: nil)
        alertController.addAction(signin)
        alertController.addAction(later)
        present(alertController, animated: true, completion: nil)
    }
    
}
