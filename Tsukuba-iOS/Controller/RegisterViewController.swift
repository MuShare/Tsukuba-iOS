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
        self.shownHeight = registerButton.frame.maxY
    }
    
    override func viewDidLayoutSubviews() {
        var minY = registerButton.frame.minY
        if UIDevice.current.isX() {
            minY += 100
        }
        self.shownHeight = minY
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
            showTip(R.string.localizable.register_not_validate())
            return
        }
        if !isEmailAddress(emailTextField.text!) {
            showTip(R.string.localizable.email_invalidate())
            return
        }
        
        finishEdit()
        startAnimating()
        
        user.register(email: emailTextField.text!,
                      name: usernameTextField.text!,
                      password: passwordTextField.text!)
        { (success, message) in
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
