//
//  ResetViewController.swift
//  Httper
//
//  Created by 李大爷的电脑 on 08/02/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ResetViewController: EditingViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendEmailSuccessImageView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!

    
    let user = UserManager.sharedInstance
    var submit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set background image
        self.view.insertSubview({
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            view.image = UIImage(named: "login-bg.jpg")
            return view
        }(), at: 0)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        self.shownHeight = submitButton.frame.minY
    }

    // MARK: - Action
    @IBAction func back(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submit(_ sender: Any) {
        // If email is submitted before, back to sign in view
        if submit {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        if !isEmailAddress(emailTextField.text!) {
            showTip(NSLocalizedString("reset_password_not_validate", comment: ""))
            return
        }
        
        finishEdit()
        startAnimating()
    
        user.reset(email: emailTextField.text!) { (success, message) in
            self.stopAnimating()

            if (success) {
                // Set submit flag to true
                self.submit = true
                // Hide tip and email text field
                self.tipLabel.isHidden = true
                self.emailTextField.isHidden = true
                // Show success image.
                self.sendEmailSuccessImageView.isHidden = false
                self.submitButton.setTitle(NSLocalizedString("back_to_login", comment: ""), for: .normal)
                self.titleLabel.text = NSLocalizedString("reset_password_check_email", comment: "")
            } else {
                self.showTip(message!)
            }
        }
    }
    
}
