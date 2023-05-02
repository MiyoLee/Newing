import Foundation
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import FirebaseAnalytics
import GoogleSignIn

class JoinViewModel {
    
    func signInWithEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { signInResult, error in
            // guard let strongSelf = self else { return }
            if error != nil {
                completion(error)
                return
            }
            // UserDefaults 초기화
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                UserDefaults.standard.removeObject(forKey: key.description)
            }
            // UserDefaults에 로그인 정보 저장
            if let userId = signInResult?.user.uid {
                UserDefaults.standard.set(userId, forKey: Constants.USER_ID)
            }
            UserDefaults.standard.set(email, forKey: Constants.EMAIL_ADDRESS)
            UserDefaults.standard.set(nil, forKey: Constants.FULL_NAME)
            UserDefaults.standard.set(nil, forKey: Constants.GIVEN_NAME)
            UserDefaults.standard.set(nil, forKey: Constants.FAMILY_NAME)
            UserDefaults.standard.set(nil, forKey: Constants.PROFILE_PIC_URL)
            
            completion(nil)
        }
    }

    func signInWithGoogle(presentingVC: UIViewController, completion: @escaping (Error?) -> Void) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if error != nil {
                completion(error)
                return
            }
            // 인증을 해도 계정은 따로 등록을 해주어야 한다.
            // 구글 인증 토큰 받아서 -> 사용자 정보 토큰 생성 -> 파이어베이스 인증에 등록
            guard
                let authentication = signInResult?.user,
                let idToken = signInResult?.user.idToken?.tokenString
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken.tokenString)
            
            // 사용자 정보 등록
            Auth.auth().signIn(with: credential) { _, _ in
                if error != nil {
                    completion(error)
                    return
                }
                // 사용자 등록 후에 처리할 코드
                guard let userId = Auth.auth().currentUser?.uid else {
                    let error = NSError(domain: "com.miyo.newing", code: 0, userInfo: [NSLocalizedDescriptionKey: "User ID is nil"])
                    completion(error)
                    return
                }
                UserDefaults.standard.set(userId, forKey: Constants.USER_ID)
                // google 프로필 정보 저장
                if let email = signInResult?.user.profile?.email {
                    UserDefaults.standard.set(email, forKey: Constants.EMAIL_ADDRESS)
                }
                if let name = signInResult?.user.profile?.name {
                    UserDefaults.standard.set(name, forKey: Constants.FULL_NAME)
                }
                if let givenName = signInResult?.user.profile?.givenName {
                    UserDefaults.standard.set(givenName, forKey: Constants.GIVEN_NAME)
                }
                if let familyName = signInResult?.user.profile?.familyName {
                    UserDefaults.standard.set(familyName, forKey: Constants.FAMILY_NAME)
                }
                if let profilePicUrl = signInResult?.user.profile?.imageURL(withDimension: 320) {
                    UserDefaults.standard.set(profilePicUrl, forKey: Constants.PROFILE_PIC_URL)
                }
                
                completion(nil)
                return
            }
        }
    }
    
    func signInWithApple(currentNonce: String?, authorization: ASAuthorization, completion: @escaping (Error?) -> Void) {
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
                    completion(error)
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
                
                completion(nil)
            }
        }
    }
    func signOut(completion: @escaping (Bool, Error?) -> Void) {
        if UserDefaults.standard.object(forKey: Constants.APPLE_USER_ID) != nil { // 애플로그인 상태일 경우
            completion(true, nil)
        } else {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                // 저장된 유저 정보 초기화
                for key in UserDefaults.standard.dictionaryRepresentation().keys {
                    UserDefaults.standard.removeObject(forKey: key.description)
                }
            } catch let signOutError as NSError {
                completion(false, signOutError)
            }
            completion(false, nil)
        }
    }
    func createAccount(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                completion(nil, error)
            } else {
                completion(result, nil)
            }
        }
    }
    
    func deleteAccount(completion: @escaping (Error?) -> Void) {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func reauthenticate() {
        var credential: AuthCredential
        let user = Auth.auth().currentUser
        if let providerData = user!.providerData.first {
            let providerID = providerData.providerID
            switch providerID {
            case "google.com":
                credential = GoogleAuthProvider.credential(withIDToken: "", accessToken: "")
            case "apple.com":
                print("")
            default:
                credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: "password")
                print("")
            }
        }
        
        // Prompt the user to re-provide their sign-in credentials
        
//        user?.reauthenticate(with: credential) { result, error  in
//            if error != nil {
//                // An error happened.
//            } else {
//                // User re-authenticated.
//            }
//        }
    }
}
