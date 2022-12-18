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
        viewHeader.addSubview(btnProfile)
        //set image
        btnProfile.setImage(UIImage(systemName: "person.circle"), for: .normal)
        btnProfile.tintColor = .darkGray
        //constraint
        btnProfile.translatesAutoresizingMaskIntoConstraints = false //contraint를 주기 위해서 false로 설정
        btnProfile.centerYAnchor.constraint(equalTo: viewHeader.centerYAnchor).isActive = true
        btnProfile.heightAnchor.constraint(equalTo: viewHeader.heightAnchor).isActive = true
        btnProfile.trailingAnchor.constraint(equalTo: viewHeader.trailingAnchor, constant: -20).isActive = true
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
        
    }
    
    @IBAction func btnClicked(_ sender: UIButton?) {
        
//        if sender === btnProfile {
//            //LoginViewController로 이동
//            guard let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginViewControllerID") as? LoginViewController else { return }
//
//            loginViewController.modalTransitionStyle = .coverVertical
//            loginViewController.modalPresentationStyle = .fullScreen
//
//            self.present(loginViewController, animated: true, completion: nil)
//        }
        
    }
    
}

