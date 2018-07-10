import UIKit
import NVActivityIndicatorView

class RegisterViewController: LoginBaseViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerSuccessImageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    let user = UserManager.shared
    
    var registered = false

    override func viewDidLoad() {
        super.viewDidLoad()

        registerButton.layer.borderColor = UIColor.lightGray.cgColor
        shownHeight = registerButton.frame.maxY
    }
    
    override func viewDidLayoutSubviews() {
        var minY = registerButton.frame.minY
        if UIDevice.current.isX() {
            minY += 100
        }
        shownHeight = minY
    }
    
    // MARK: - Action
    @IBAction func back(_ sender: Any) {
        if registered {
            if let loginViewController = navigationController?.viewControllers[0] as? LoginViewController {
                loginViewController.emailTextField.text = emailTextField.text
                loginViewController.passwordTextField.text = passwordTextField.text
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func register(_ sender: Any) {
        if registered {
            back(registerButton)
            return
        }
        guard let email = emailTextField.text,
            let username = usernameTextField.text,
            let password = passwordTextField.text else {
            return
        }
        if email == "" || username == "" || password == "" {
            showTip(R.string.localizable.register_not_validate())
            return
        }
        if !email.isEmailAddress {
            showTip(R.string.localizable.email_invalidate())
            return
        }
        
        finishEdit()
        startAnimating()
        
        user.register(email: email, name: username, password: password) { [weak self] (success, message) in
            guard let `self` = self else {
                return
            }
            self.stopAnimating()
            
            if (success) {
                self.registered = true
                self.emailTextField.isHidden = true
                self.passwordTextField.isHidden = true
                self.usernameTextField.isHidden = true
                self.registerSuccessImageView.isHidden = false
                self.registerButton.setTitle(R.string.localizable.back_to_login(), for: .normal)
            } else {
                if message != nil {
                    self.showTip(message!)
                }
            }
        }
    }

}
