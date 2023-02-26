//
//  BaseViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/09.
//

import UIKit
import DropDown
import Firebase
import GoogleSignIn
import AuthenticationServices
import SafeAreaBrush

class BaseViewController: UIViewController {
    
    var viewHeader: UIView = UIView(frame: CGRect(x: 0, y: 30, width:0, height:60))
    var IvLogo = UIImageView(image:UIImage(named: "newing_logo"))
    var btnProfile = UIButton()
    var btnBack = UIButton()
    var btnGoLink = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    func addHeader(type: Int) {
        viewHeader.frame.size.width = view.bounds.size.width    //너비 설정
        viewHeader.backgroundColor = UIColor(rgb: 0xD2DAFF)
        fillSafeArea(position: .top, color: UIColor(rgb: 0xD2DAFF))
        self.view.addSubview(viewHeader)
        
        addHeaderItems(view: viewHeader, type: type)
    }
    
    func addHeaderItems(view: UIView, type: Int){
        switch type {
        case 1:
            //탭 메인. 로고, 프로필
            addLogo()
            addProfile()
            
        case 2:
            // 뉴스 상세페이지. 뒤로가기, go link
            addBtnBack()
            addBtnGoLink()
        case 3:
            // 로그인 페이지. 뒤로가기.
            addBtnBack()
        default:
            print("default")
        }
        
    }
    
    func addLogo() {
        viewHeader.addSubview(IvLogo)
        IvLogo.translatesAutoresizingMaskIntoConstraints = false //contraint를 주기 위해서 false로 설정
        IvLogo.centerYAnchor.constraint(equalTo: viewHeader.centerYAnchor).isActive = true
        IvLogo.leadingAnchor.constraint(equalTo: viewHeader.leadingAnchor, constant: 10).isActive = true
        IvLogo.heightAnchor.constraint(equalTo: viewHeader.heightAnchor).isActive = true
        IvLogo.widthAnchor.constraint(equalTo: viewHeader.heightAnchor).isActive = true
    }
    
    func addProfile() {
        btnProfile.removeFromSuperview()
        viewHeader.addSubview(btnProfile)
        btnProfile.setTitleColor(.systemIndigo, for: .normal)
        if UserDefaults.standard.object(forKey: Constants.USER_ID) != nil || UserDefaults.standard.object(forKey: Constants.APPLE_USER_ID) != nil {    // 로그인 상태일 때
            if let givenName = UserDefaults.standard.string(forKey: Constants.GIVEN_NAME) {  // 구글 or 애플 로그인 상태일때
                btnProfile.setTitle(givenName, for: .normal)
            } else {
                if var email = UserDefaults.standard.object(forKey: Constants.EMAIL_ADDRESS) {   // 자체로그인 상태일때
                    let emailString = email as! String
                    var tokens = emailString.components(separatedBy: "@")
                    let IdFromEmail = tokens[0]
                    btnProfile.setTitle(IdFromEmail, for: .normal)
                } else {
                    btnProfile.setTitle("이름 없는 사용자", for: .normal)
                }
            }
        } else {    // 로그아웃 상태일 때
            btnProfile.setTitle("Sign in", for: .normal)
        }
        
        //constraint
        btnProfile.translatesAutoresizingMaskIntoConstraints = false //contraint를 주기 위해서 false로 설정
        btnProfile.centerYAnchor.constraint(equalTo: viewHeader.centerYAnchor).isActive = true
        btnProfile.heightAnchor.constraint(equalTo: viewHeader.heightAnchor).isActive = true
        btnProfile.trailingAnchor.constraint(equalTo: viewHeader.trailingAnchor, constant: -20).isActive = true
        
        //클릭 이벤트
        btnProfile.addTarget(self, action: "btnProfileClicked:", for: .touchUpInside)
    }
    
    func addBtnBack() {
        viewHeader.addSubview(btnBack)
        
        btnBack.setTitle("", for: .normal)
        btnBack.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        btnBack.tintColor = UIColor.black
        btnBack.translatesAutoresizingMaskIntoConstraints = false
        btnBack.centerYAnchor.constraint(equalTo: viewHeader.centerYAnchor).isActive = true
        btnBack.leadingAnchor.constraint(equalTo: viewHeader.leadingAnchor, constant: 10).isActive = true
        btnBack.heightAnchor.constraint(equalTo: viewHeader.heightAnchor).isActive = true
        
        //클릭 이벤트
        btnBack.addTarget(self, action: "btnBackClicked:", for: .touchUpInside)
    }
    
    func addBtnGoLink() {
        viewHeader.addSubview(btnGoLink)
        
        btnGoLink.setTitle("Go Link", for: .normal)
        btnGoLink.setTitleColor(UIColor.systemIndigo, for: .normal)
        btnGoLink.translatesAutoresizingMaskIntoConstraints = false
        btnGoLink.heightAnchor.constraint(equalTo: viewHeader.heightAnchor).isActive = true
        btnGoLink.trailingAnchor.constraint(equalTo: viewHeader.trailingAnchor, constant: -10).isActive = true
        
        //클릭 이벤트
        btnGoLink.addTarget(self, action: "btnGoLinkClicked:", for: .touchUpInside)
    }
    
    func addBtnPlus() {
        
        let btnPlus = UIButton()
        self.view.addSubview(btnPlus)
        self.view.bringSubviewToFront(btnPlus)
        
        btnPlus.setTitle("", for: .normal)
        btnPlus.setImage(UIImage(systemName: "plus"), for: .normal)
        btnPlus.backgroundColor = .systemIndigo
        btnPlus.tintColor = UIColor(rgb: 0xD2DAFF)
        btnPlus.layer.cornerRadius = 25
        btnPlus.layer.cornerCurve = .continuous
        btnPlus.layer.shadowColor = UIColor.gray.cgColor
        btnPlus.layer.shadowOpacity = 1.0
        btnPlus.layer.shadowOffset = CGSize(width: 3, height: 3)
        btnPlus.layer.shadowRadius = 6
        btnPlus.layer.zPosition = 999
        //constraint
        btnPlus.translatesAutoresizingMaskIntoConstraints = false //contraint를 주기 위해서 false로 설정
        btnPlus.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btnPlus.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnPlus.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        btnPlus.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        //클릭 이벤트
        btnPlus.addTarget(self, action: "btnPlusClicked:", for: .touchUpInside)
        
    }
    
    func addBtnMemo() {
        
        let btnMemo = UIButton()
        self.view.addSubview(btnMemo)
        self.view.bringSubviewToFront(btnMemo)
        
        btnMemo.setTitle("", for: .normal)
        btnMemo.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        btnMemo.backgroundColor = .systemIndigo
        btnMemo.tintColor = UIColor(rgb: 0xD2DAFF)
        btnMemo.layer.cornerRadius = 25
        btnMemo.layer.cornerCurve = .continuous
        btnMemo.layer.shadowColor = UIColor.gray.cgColor
        btnMemo.layer.shadowOpacity = 1.0
        btnMemo.layer.shadowOffset = CGSize(width: 3, height: 3)
        btnMemo.layer.shadowRadius = 6
        btnMemo.layer.zPosition = 999
        //constraint
        btnMemo.translatesAutoresizingMaskIntoConstraints = false //contraint를 주기 위해서 false로 설정
        btnMemo.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btnMemo.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnMemo.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        btnMemo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        //클릭 이벤트
        btnMemo.addTarget(self, action: "btnMemoClicked:", for: .touchUpInside)
        
    }
    
    @IBAction func btnProfileClicked(_ sender: UIButton?) {
        
        if UserDefaults.standard.object(forKey: Constants.USER_ID) != nil || UserDefaults.standard.object(forKey: Constants.APPLE_USER_ID) != nil{ //로그인 상태일때
            // dropdown 메뉴에 sign out 나오게
            let dropdown = DropDown()
            let itemList = ["Sign Out"]
            dropdown.dataSource = itemList
            dropdown.anchorView = btnProfile
            dropdown.bottomOffset = CGPoint(x: 0, y: btnProfile.bounds.height)
            
            // Item 선택 시 처리
            dropdown.selectionAction = { [weak self] (index, item) in
                if item == "Sign Out" {     //로그아웃 처리
                    if UserDefaults.standard.object(forKey: Constants.APPLE_USER_ID) != nil { // 애플로그인 상태일 경우
                        self?.popAlert(title: "Please Sign out from the path below.", message: "Settings > [User Name] > Password & Security > Apps Using Apple ID > Stop Using Apple ID") {
                            
                        }
                    } else {
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            // 저장된 유저 정보 초기화
                            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                                UserDefaults.standard.removeObject(forKey: key.description)
                            }
                        } catch let signOutError as NSError {
                            print("로그아웃 Error발생:", signOutError)
                        }
                        // 모든 탭화면 초기화.
                        self!.initTabs()
                    }
                }
            }
            // 취소 시 처리
            dropdown.cancelAction = { [weak self] in
                //빈 화면 터치 시 DropDown이 사라짐
                dropdown.hide()
            }
            dropdown.show()
            
        } else {    // 로그아웃 상태일때
            // LoginViewController로 이동
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController else { return }
            
            loginVC.modalPresentationStyle = .fullScreen
            
            self.present(loginVC, animated: false, completion: nil)
        }
        
    }
    
    func initTabs() {
        if let tvc = self.view.window?.rootViewController as? UITabBarController {
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
    
    func popAlert(title: String?, message: String?, actionForOK: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if actionForOK != nil {
                actionForOK()
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: false, completion: nil)
    }
    
    func popConfirm(title: String?, message: String?, actionForYes: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default) { action in
          //취소처리. 아무것도 안함.
        })
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { action in
          //확인처리
            actionForYes()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
}

