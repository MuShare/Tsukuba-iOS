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
    
    func closeView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func hideFooterView(for tableView: UITableView) {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView?.backgroundColor = UIColor.clear
    }

}
