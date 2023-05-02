import UIKit
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth

class JoinViewController: BaseViewController {
    
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHeader(type: 3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        initTabs()
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func btnCreateAccountTouched(_ sender: Any) {
        if let email = tfEmail.text, let password = tfPassword.text {
            joinViewModel.createAccount(email: email, password: password){ result, error in
                if error == nil && result != nil {
                    self.popAlert(title: "Welcome!", message: "Your account has been created."){}
                    self.dismiss(animated: true)
                }
            }
        } else {
            popAlert(title: nil, message: "Invalid email or password"){}
        }
    }
}
