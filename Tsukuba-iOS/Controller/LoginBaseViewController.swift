//
//  LoginBaseViewController.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/05/29.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class LoginBaseViewController: EditingViewController {
    
    private lazy var backgroundImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        view.image = R.image.loginBgJpg()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubview(backgroundImageView, at: 0)
    }
    
}
