//
//  LoginViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/12/18.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var btnGoogleSignIn: GIDSignInButton!
    @IBOutlet weak var btnSignOut: UIButton!
    
    let signInConfig = GIDConfiguration.init(clientID: "988262783630-orr4r2c5ohbl5ogur8pgbvbb36ekbb5j.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        if UserDefaults.standard.object(forKey: "emailAddress") != nil {    // 로그인 상태
            btnGoogleSignIn.isHidden = true
            btnSignOut.isHidden = false
        } else {    // 로그아웃 상태
            btnGoogleSignIn.isHidden = false
            btnSignOut.isHidden = true
        }
        btnGoogleSignIn.style = .wide
    }
    
    @IBAction func btnGoogleSignInTouched(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(with: self.signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            // 로그인 성공시
            // 1. 로그인 유저 정보 UserDefaults에 저장
            UserDefaults.standard.set(user.profile?.email, forKey: "emailAddress")
            UserDefaults.standard.set(user.profile?.name, forKey: "fullName")
            UserDefaults.standard.set(user.profile?.givenName, forKey: "givenName")
            UserDefaults.standard.set(user.profile?.familyName, forKey: "familyName")
            UserDefaults.standard.set(user.profile?.imageURL(withDimension: 320), forKey: "profilePicUrl")
            
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func btnSignOutTouched(_ sender: Any) {
        GIDSignIn.sharedInstance.signOut()  // 구글 로그아웃
        
        // 저장된 유저 정보 초기화
        UserDefaults.standard.set(nil, forKey: "emailAddress")
        UserDefaults.standard.set(nil, forKey: "fullName")
        UserDefaults.standard.set(nil, forKey: "givenName")
        UserDefaults.standard.set(nil, forKey: "familyName")
        UserDefaults.standard.set(nil, forKey: "profilePicUrl")
        
        self.dismiss(animated: false)
    }
    
    @IBAction func btnBackTouched(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    // view 사라질때 호출됨
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tvc = self.presentingViewController as? UITabBarController {
            if let vcs = tvc.viewControllers, !vcs.isEmpty {
                for vc in vcs {
                    if let vc = vc as? BaseViewController {
                        vc.addProfile()
                    }
                }
            }
        }
        
    }
}
