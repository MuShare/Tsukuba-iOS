//
//  RegisterViewController.swift
//  Httper
//
//  Created by 李大爷的电脑 on 04/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: EditingViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerSuccessImageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    let user = UserManager.sharedInstance
    
    var registered = false

    override func viewDidLoad() {
        super.viewDidLoad()

        registerButton.layer.borderColor = UIColor.lightGray.cgColor
        self.shownHeight = registerButton.frame.maxY
        
        //Set background image
        let backgroundImageView: UIImageView = {
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            let ratio = view.frame.size.height / view.frame.size.width
            view.image = UIImage(named: ratio == 4 / 3 ? "register-bg-iPad.jpg" : "login-bg.jpg")
            return view
        }()
        self.view.insertSubview(backgroundImageView, at: 0)
    }
    
    // MARK: - Action
    @IBAction func back(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func register(_ sender: Any) {
        if registered {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        if emailTextField.text == "" || usernameTextField.text == "" || passwordTextField.text == "" {
            showAlert(title: NSLocalizedString("tip_name", comment: ""),
                      content: NSLocalizedString("register_not_validate", comment: ""),
                      controller: self)
            return
        }
        if !isEmailAddress(emailTextField.text!) {
            showAlert(title: NSLocalizedString("tip_name", comment: ""),
                      content: NSLocalizedString("email_invalidate", comment: ""),
                      controller: self)
            return
        }
        
        registerButton.isEnabled = false
        loadingActivityIndicatorView.startAnimating()
        user.register(email: emailTextField.text!,
                      name: usernameTextField.text!,
                      password: passwordTextField.text!)
        { (success, message) in
            self.registerButton.isEnabled = true
            self.loadingActivityIndicatorView.stopAnimating()
            self.finishEdit()
            if (success) {
                self.registered = true
                self.emailTextField.isHidden = true
                self.passwordTextField.isHidden = true
                self.usernameTextField.isHidden = true
                self.registerSuccessImageView.isHidden = false
                self.registerButton.setTitle(NSLocalizedString("back_to_login", comment: ""), for: .normal)
            } else {
                if message != nil {
                    showAlert(title: NSLocalizedString("tip_name", comment: ""),
                              content: message!,
                              controller: self)
                }
            }
        }
    }

}