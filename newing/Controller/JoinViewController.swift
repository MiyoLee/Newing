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
        
    }
    
    
    @IBAction func btnCreateAccountTouched(_ sender: Any) {
        if let email = tfEmail.text, let password = tfPassword.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error)
                }
                print("createUser 결과: \(authResult)")
                // 회원가입 성공 alert
                self.popAlert(title: "Thank you!", message: "Sign up is Complete.\nPlease Sign in.")
            }
        } else {
            print("Invalid email or password")
        }
    }
    
    @IBAction func btnBackTouched(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
