//
//  AppDelegate.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/04.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // AppDelegate 기본 제공 메소드 start -----------------------------------------------
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // 앱 시작시 이전 로그인 정보 불러오기
//        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//            if error != nil || user == nil {
//                // Show the app's signed-out state.
//            } else {
//                // Show the app's signed-in state.
//            }
//        }
        
        // 애플 로그인 관련 소스. 필요 없을것 같기도 한데...
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: UserDefaults.standard.string(forKey: "appleUserId") ?? "") { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    print("authorized")
                    break
                case .revoked:
                    print("revoked")
                    UserDefaults.standard.set(nil, forKey: "appleUserId")
                    UserDefaults.standard.set(nil, forKey: "userId")
                    UserDefaults.standard.set(nil, forKey: "emailAddress")
                    UserDefaults.standard.set(nil, forKey: "fullName")
                    UserDefaults.standard.set(nil, forKey: "givenName")
                    UserDefaults.standard.set(nil, forKey: "familyName")
                    UserDefaults.standard.set(nil, forKey: "profilePicUrl")
                    break
                case .notFound:
                    print("notFound")
                    UserDefaults.standard.set(nil, forKey: "appleUserId")
                    UserDefaults.standard.set(nil, forKey: "userId")
                    UserDefaults.standard.set(nil, forKey: "emailAddress")
                    UserDefaults.standard.set(nil, forKey: "fullName")
                    UserDefaults.standard.set(nil, forKey: "givenName")
                    UserDefaults.standard.set(nil, forKey: "familyName")
                    UserDefaults.standard.set(nil, forKey: "profilePicUrl")
                default:
                    break
                }
            }
        
        return true
        
    }
    
    // 인증 절차의 마지막에 받은 URL을 처리하기 위해서 필요한 메서드입니다.
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // Handle other custom URL types.
        
        // if not handled by this app, return false.
        return false
        
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // rootViewController 설정
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let headlineViewController = storyboard.instantiateViewController(withIdentifier: "HeadlineVC") as! HeadlineViewController
//
//        window?.rootViewController = headlineViewController
//        window?.makeKeyAndVisible()
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    
}

