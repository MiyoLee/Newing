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
import CryptoKit

class LoginViewController: BaseViewController {
    
    
    @IBOutlet weak var vSignIn: UIView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var svSocialLogin: UIStackView!
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHeader(type: 3)
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
        if UserDefaults.standard.object(forKey: Constants.USER_ID) != nil {    // 로그인 상태
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
        btnAppleSignIn.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        
    }
    
    // 인증을 처리할 메서드
//    @objc func handleAuthorizationAppleIDBtnPressed() {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        // 이름과 이메일 요청
//        request.requestedScopes = [.fullName, .email]
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
    
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
                UserDefaults.standard.set(userId, forKey: Constants.USER_ID)
                // google 프로필 정보 저장
                UserDefaults.standard.set(user!.profile?.email, forKey: Constants.EMAIL_ADDRESS)
                UserDefaults.standard.set(user!.profile?.name, forKey: Constants.FULL_NAME)
                UserDefaults.standard.set(user!.profile?.givenName, forKey: Constants.GIVEN_NAME)
                UserDefaults.standard.set(user!.profile?.familyName, forKey: Constants.FAMILY_NAME)
                UserDefaults.standard.set(user!.profile?.imageURL(withDimension: 320), forKey: Constants.PROFILE_PIC_URL)
                
                // 로그인 창 닫기
                self.dismiss(animated: false)
            }
            
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func btnSignInTouched(_ sender: Any) {    // 뉴잉 로그인
        if let email = tfEmail.text, let password = tfPassword.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                // guard let strongSelf = self else { return }
                if error != nil {
                    print(error!)
                    self?.popAlert(title: "Sign in failed.", message: error?.localizedDescription){
                        
                    }
                } else {
                    // UserDefaults 초기화
                    for key in UserDefaults.standard.dictionaryRepresentation().keys {
                        UserDefaults.standard.removeObject(forKey: key.description)
                    }
                    // UserDefaults에 로그인 정보 저장
                    if let userId = authResult?.user.uid {
                        UserDefaults.standard.set(userId, forKey: Constants.USER_ID)
                    }
                    UserDefaults.standard.set(email, forKey: Constants.EMAIL_ADDRESS)
                    UserDefaults.standard.set(nil, forKey: Constants.FULL_NAME)
                    UserDefaults.standard.set(nil, forKey: Constants.GIVEN_NAME)
                    UserDefaults.standard.set(nil, forKey: Constants.FAMILY_NAME)
                    UserDefaults.standard.set(nil, forKey: Constants.PROFILE_PIC_URL)
                    
                    self?.dismiss(animated: false)
                }
            }
            
        } else {
            print("Please enter both email and password.")
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
        initTabs()
    }
}

// Apple 로그인 관련...
extension LoginViewController {
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print ("Error Apple sign in: %@", error)
                    return
                }
                
                guard let userId = Auth.auth().currentUser?.uid else { return }
                
                // User is signed in to Firebase with Apple.
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                let givenName = fullName?.givenName ?? ""
                let familyName = fullName?.familyName ?? ""
                
                for key in UserDefaults.standard.dictionaryRepresentation().keys {
                    UserDefaults.standard.removeObject(forKey: key.description)
                }
                UserDefaults.standard.set(userId,forKey: Constants.USER_ID)
                UserDefaults.standard.set(userIdentifier , forKey: Constants.APPLE_USER_ID)
                UserDefaults.standard.set(givenName, forKey: Constants.GIVEN_NAME)
                UserDefaults.standard.set(familyName, forKey: Constants.FAMILY_NAME)
                UserDefaults.standard.set(givenName + " " + familyName, forKey: Constants.FULL_NAME)
                UserDefaults.standard.set(email ?? "", forKey: Constants.EMAIL_ADDRESS)
                
                self.dismiss(animated: false)
            }
        }
    }
}

func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // 에러 처리
    print("애플로그인 에러: \(error)")
}
