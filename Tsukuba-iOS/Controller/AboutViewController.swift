import UIKit

class AboutViewController: UIViewController {
    
    deinit {
        print("deinit \(type(of: self))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setCustomBack()
    }
    
}
