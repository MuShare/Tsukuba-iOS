import UIKit
import FacebookCore
import FacebookLogin
import NVActivityIndicatorView

class LoginViewController: LoginBaseViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var facebookLoadingActivityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        var minY = loginButton.frame.minY
        if UIDevice.current.isX() {
            minY += 100
        }
        self.shownHeight = minY
    }

    // MARK: - Action
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        if emailTextField.text == "" || !isEmailAddress(emailTextField.text!) || passwordTextField.text == "" {
            showTip(R.string.localizable.login_not_validate())
            return
        }
        
        finishEdit()
        startAnimating()
        
        UserManager.shared.login(email: emailTextField.text!, password: passwordTextField.text!) { (success, message) in
            self.stopAnimating()
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showTip(message!)
            }
        }
        
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: self) { loginResult in
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
                self.startAnimating()
                UserManager.shared.facebookLogin(accessToken.authenticationToken, completion: { (success, message) in
                    self.stopAnimating()
                    if success {
                        self.dismiss(animated: true)
                    } else {
                        self.showTip(message!)
                    }
                })
            }
        }

    }
    
}
