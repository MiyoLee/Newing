//
//  JoinViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/12/23.
//

import UIKit
import Firebase

class JoinViewController: BaseViewController {
    
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHeader(type: 3)
    }
    
    
    @IBAction func btnCreateAccountTouched(_ sender: Any) {
        if let email = tfEmail.text, let password = tfPassword.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error)
                }
                print("createUser 결과: \(authResult)")
                // 회원가입 성공 alert
                self.popAlert(title: "Thank you!", message: "Sign up is Complete.\nPlease Sign in.") {
                    self.dismiss(animated: false)
                }
            }
        } else {
            print("Invalid email or password")
        }
    }
}
