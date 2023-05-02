import UIKit
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import GoogleSignIn

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
        
        btnGoogleSignIn.addTarget(self, action: #selector(handleGoogleSignIn(_:)), for: .touchUpInside)
        
        // 애플로그인 버튼
        let btnAppleSignIn = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        // 스택뷰에 애플 로그인 버튼 추가
        svSocialLogin.addArrangedSubview(btnAppleSignIn)
        
        btnAppleSignIn.translatesAutoresizingMaskIntoConstraints = false
        btnAppleSignIn.widthAnchor.constraint(equalToConstant: 194).isActive = true
        
        // 버튼 눌렀을 때 처리할 메서드 추가
        btnAppleSignIn.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        
    }
    
    
    @IBAction func handleGoogleSignIn(_ sender: Any) {
        joinViewModel.signInWithGoogle(presentingVC: self){ error in
            if error != nil {
                self.popAlert(title: "Error", message: "Failed to google sign in. Please try again."){ return }
            } else {
                self.dismiss(animated: false)
            }
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func btnSignInTouched(_ sender: Any) {    // 이메일 로그인
        if !tfEmail.text!.isEmpty && !tfPassword.text!.isEmpty {
            joinViewModel.signInWithEmail(email: tfEmail.text!, password: tfPassword.text!){ error in
                if error != nil {
                    self.popAlert(title: "Fail", message: "Please check your email and password."){ return }
                } else {
                    self.dismiss(animated: true)
                }
            }
        } else {
            self.popAlert(title: "Fail", message: "Please enter your email and password."){}
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
    // 이거 joinViewModel로 빼기, 탈퇴시 재인증 과정에서 호출하기
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
    
    // 성공시 인증 정보를 반환받는다.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        joinViewModel.signInWithApple(currentNonce: currentNonce, authorization: authorization){ error in
            if error != nil {
                self.popAlert(title: "Error", message: "Failed to sign in with Apple. Please try again."){}
            } else {
                self.dismiss(animated: false)
            }
        }
    }
}

func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // 에러 처리
    print("애플로그인 에러: \(error)")
}
