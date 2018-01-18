//
//  LicenseViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 18/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class LicenseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
         _ = self.navigationController?.popViewController(animated: true)
    }
    
}
