import UIKit
import NVActivityIndicatorView

class RegisterViewController: EditingViewController, NVActivityIndicatorViewable {

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
            view.image = UIImage(named: "login-bg.jpg")
            return view
        }()
        self.view.insertSubview(backgroundImageView, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        self.shownHeight = registerButton.frame.minY
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
            showTip(NSLocalizedString("register_not_validate", comment: ""))
            return
        }
        if !isEmailAddress(emailTextField.text!) {
            showTip(NSLocalizedString("email_invalidate", comment: ""))
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
                self.registerButton.setTitle(NSLocalizedString("back_to_login", comment: ""), for: .normal)
            } else {
                if message != nil {
                    self.showTip(message!)
                }
            }
        }
    }

}
