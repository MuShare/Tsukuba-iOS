//
//  LicenseViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 18/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class LicenseViewController: LoginBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func back(_ sender: Any) {
         _ = self.navigationController?.popViewController(animated: true)
    }
    
}
