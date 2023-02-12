//
//  LoginViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/12/18.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController{
    

    @IBOutlet weak var vSignIn: UIView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!

    @IBOutlet weak var svSocialLogin: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
   
    
    
    func setUpView() {
        setupProviderLoginView()    // 애플, 구글로그인 버튼 세팅
        
        // 디자인 세팅
        tfEmail.layer.borderWidth = 1
        tfEmail.layer.borderColor = UIColor.systemIndigo.cgColor
        tfEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.systemIndigo])
        tfPassword.layer.borderWidth = 1
        tfPassword.layer.borderColor = UIColor.systemIndigo.cgColor
        tfPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.systemIndigo])
        
        // 버튼 노출 세팅
        if UserDefaults.standard.object(forKey: "userId") != nil {    // 로그인 상태
            vSignIn.isHidden = true
            btnSignUp.isHidden = true
            svSocialLogin.isHidden = true
        } else {    // 로그아웃 상태
            vSignIn.isHidden = false
            btnSignUp.isHidden = false
            svSocialLogin.isHidden = false
        }
    }
    
    func setupProviderLoginView() {
        svSocialLogin.spacing = 10
        svSocialLogin.alignment = .center
        // 구글로그인 버튼
        let btnGoogleSignIn = GIDSignInButton()
        svSocialLogin.addArrangedSubview(btnGoogleSignIn)
        btnGoogleSignIn.style = .wide
        btnGoogleSignIn.colorScheme = .dark
        
        btnGoogleSignIn.translatesAutoresizingMaskIntoConstraints = false
        btnGoogleSignIn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        btnGoogleSignIn.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        
        // 애플로그인 버튼
        let btnAppleSignIn = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        // 스택뷰에 애플 로그인 버튼 추가
        svSocialLogin.addArrangedSubview(btnAppleSignIn)
        
        btnAppleSignIn.translatesAutoresizingMaskIntoConstraints = false
        btnAppleSignIn.widthAnchor.constraint(equalToConstant: 194).isActive = true
        
        // 버튼 눌렀을 때 처리할 메서드 추가
        btnAppleSignIn.addTarget(self, action: #selector(handleAuthorizationAppleIDBtnPressed), for: .touchUpInside)
        
    }
    
    // 인증을 처리할 메서드
    @objc
    func handleAuthorizationAppleIDBtnPressed() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // 이름과 이메일 요청
        request.requestedScopes = [.fullName, .email]
     
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func handleGoogleSignIn(_ sender: Any) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let signInConfig = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard user != nil else { return }
            // 인증을 해도 계정은 따로 등록을 해주어야 한다.
            // 구글 인증 토큰 받아서 -> 사용자 정보 토큰 생성 -> 파이어베이스 인증에 등록
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            // 사용자 정보 등록
            Auth.auth().signIn(with: credential) { _, _ in
                // 사용자 등록 후에 처리할 코드
                guard let userId = Auth.auth().currentUser?.uid else { return }
                // firebase userId 저장
                UserDefaults.standard.set(userId, forKey: "userId")
                // google 프로필 정보 저장
                UserDefaults.standard.set(user!.profile?.email, forKey: "emailAddress")
                UserDefaults.standard.set(user!.profile?.name, forKey: "fullName")
                UserDefaults.standard.set(user!.profile?.givenName, forKey: "givenName")
                UserDefaults.standard.set(user!.profile?.familyName, forKey: "familyName")
                UserDefaults.standard.set(user!.profile?.imageURL(withDimension: 320), forKey: "profilePicUrl")
                
                // 로그인 창 닫기
                self.dismiss(animated: false)
            }
            
        }
    }
    
    
    @IBAction func btnSignOutTouched(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // 저장된 유저 정보 초기화
            UserDefaults.standard.set(nil, forKey: "userId")
            UserDefaults.standard.set(nil, forKey: "emailAddress")
            UserDefaults.standard.set(nil, forKey: "fullName")
            UserDefaults.standard.set(nil, forKey: "givenName")
            UserDefaults.standard.set(nil, forKey: "familyName")
            UserDefaults.standard.set(nil, forKey: "profilePicUrl")
        } catch let signOutError as NSError {
            print("로그아웃 Error발생:", signOutError)
        }
        
        self.dismiss(animated: false)
    }
    
    @IBAction func btnBackTouched(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func btnSignInTouched(_ sender: Any) {    // 뉴잉 로그인
        if let email = tfEmail.text, let password = tfPassword.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                // guard let strongSelf = self else { return }
                guard error == nil else {
                    print(error!)
                    return
                }
                if let userId = authResult?.user.uid {
                    UserDefaults.standard.set(userId, forKey: "userId")
                }
                UserDefaults.standard.set(email, forKey: "emailAddress")
                UserDefaults.standard.set(nil, forKey: "fullName")
                UserDefaults.standard.set(nil, forKey: "givenName")
                UserDefaults.standard.set(nil, forKey: "familyName")
                UserDefaults.standard.set(nil, forKey: "profilePicUrl")
                
                self?.dismiss(animated: false)
            }
            
        } else {
            print("email, password 모두 입력해주세요.")
        }
    }
    
    @IBAction func btnSignUpTouched(_ sender: Any) {  // 회원가입 화면으로 이동
        guard let joinVC = self.storyboard?.instantiateViewController(withIdentifier: "JoinVC") as? JoinViewController else { return }
        joinVC.modalPresentationStyle = .fullScreen
        self.present(joinVC, animated: false, completion: nil)
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
                    if let vc = vc as? FavoriteViewController {
                        vc.loadSavedArticles()
                    }
                }
            }
        }
        
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("UserID: \(userIdentifier)")
            print("FullName: \(fullName)")
            print("Email: \(email)")
            
        case let passwordCredential as ASPasswordCredential:
            
            let username = passwordCredential.user
            let password = passwordCredential.password
                        
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 에러 처리
    }
}
