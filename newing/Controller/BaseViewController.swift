//
//  BaseViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/09.
//

import UIKit

class BaseViewController: UIViewController {
    
    var viewHeader: UIView = UIView(frame: CGRect(x: 0, y: 30, width:0, height:60))
    var IvLogo = UIImageView(image:UIImage(named: "newing_logo"))
    var btnProfile = UIButton()
    var btnBack = UIButton()
    var btnGoLink = UIButton()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    func addHeader(type: Int) {
        viewHeader.frame.size.width = view.bounds.size.width    //너비 설정
        viewHeader.backgroundColor = UIColor(rgb: 0xD2DAFF)
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
        if UserDefaults.standard.object(forKey: "userId") != nil {    // 로그인 상태일 때
            if let givenName = UserDefaults.standard.string(forKey: "givenName") {  // 구글로그인 상태일때
                btnProfile.setTitle(givenName, for: .normal)
            } else {
                if var email = UserDefaults.standard.object(forKey: "emailAddress") {   // 자체로그인 상태일때
                    let emailString = email as! String
                    var tokens = emailString.components(separatedBy: "@")
                    let IdFromEmail = tokens[0]
                    btnProfile.setTitle(IdFromEmail, for: .normal)
                }
            }
        } else {    // 로그아웃 상태일 때
            btnProfile.setTitle("Sign in", for: .normal)
        }
        //set image
//        btnProfile.setImage(UIImage(systemName: "person.circle"), for: .normal)
//        btnProfile.tintColor = .darkGray
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
    
    @IBAction func btnProfileClicked(_ sender: UIButton?) {
        
        //LoginViewController로 이동
        guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController else { return }
        
        loginVC.modalPresentationStyle = .fullScreen
        
        self.present(loginVC, animated: false, completion: nil)
        
    }
    
    func popAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: false) // 닫기
        }
        alert.addAction(okAction)
        self.present(alert, animated: false, completion: nil)
    }
    
    func popConfirm(title: String?, message: String?, actionForYes: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default) { action in
          //취소처리
            self.dismiss(animated: false)
        })
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { action in
          //확인처리
            actionForYes()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
}

