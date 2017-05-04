//
//  LoginViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!

    // MARK: - Action
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        if emailTextField.text == "" || !isEmailAddress(emailTextField.text!) || passwordTextField.text == "" {
            showAlert(title: NSLocalizedString("tip_name", comment: ""),
                      content: NSLocalizedString("login_not_validate", comment: ""),
                      controller: self)
            return
        }
        
        loginButton.isEnabled = false
        loadingActivityIndicatorView.startAnimating()
        
        UserManager.sharedInstance.login(email: emailTextField.text!,
                                         password: passwordTextField.text!)
        { (success, message) in
            self.loginButton.isEnabled = true
            self.loadingActivityIndicatorView.stopAnimating()
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                showAlert(title: NSLocalizedString("tip_name", comment: ""),
                          content: message!,
                          controller: self)
            }
        }
        
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        
    }

}
