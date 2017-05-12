//
//  LoginViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: EditingViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var facebookLoadingActivityIndicatorView: UIActivityIndicatorView!
    
    let user = UserManager.sharedInstance
    
    override func viewDidLoad() {
        //Set background image
        let backgroundImageView: UIImageView = {
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            let ratio = view.frame.size.height / view.frame.size.width
            view.image = UIImage(named: ratio == 4 / 3 ? "login-bg-iPad.jpg" : "login-bg.jpg")
            return view
        }()
        self.view.insertSubview(backgroundImageView, at: 0)
    }

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
        
        user.login(email: emailTextField.text!,
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
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                if DEBUG {
                    print("Facebook OAuth login error: \(error)");
                }
            case .cancelled:
                if DEBUG {
                    print("User cancelled login.");
                }
            case .success(_, _, let accessToken):
                self.facebookLoginButton.isEnabled = false
                self.facebookLoadingActivityIndicatorView.startAnimating()
                self.user.facebookLogin(accessToken.authenticationToken, completion: { (success, message) in
                    self.facebookLoginButton.isEnabled = true
                    self.facebookLoadingActivityIndicatorView.stopAnimating()
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        showAlert(title: NSLocalizedString("tip_name", comment: ""),
                                  content: message!,
                                  controller: self)
                    }
                })
            }
        }

    }

}
