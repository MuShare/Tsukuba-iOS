//
//  MessageViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 11/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import ImageSlideshow

class MessageViewController: UIViewController {

    @IBOutlet weak var picturesImageSlideshow: ImageSlideshow!
    
    var mid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
