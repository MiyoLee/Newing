//
//  BaseViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/09.
//

import UIKit

class BaseViewController: UIViewController {
    
    var IvLogo = UIImageView(image:UIImage(named: "newing_logo"))
    var btnProfile = UIButton()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    func addHeader() {
        
        let viewHeader: UIView = UIView(frame: CGRect(x: 0, y: 30, width:self.view.bounds.size.width, height:60))
        viewHeader.backgroundColor = UIColor(rgb: 0xD2DAFF)
        self.view.addSubview(viewHeader)
        
        addHeaderItems(view: viewHeader)
        
    }
    
    func addHeaderItems(view: UIView){

        //로고 추가
        view.addSubview(IvLogo)
        IvLogo.translatesAutoresizingMaskIntoConstraints = false //contraint를 주기 위해서 false로 설정
        IvLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        IvLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        IvLogo.heightAnchor.constraint(equalToConstant: 60).isActive = true
        IvLogo.widthAnchor.constraint(equalToConstant: 60).isActive = true
        //프로필 버튼 추가
        view.addSubview(btnProfile)
        //set image
        btnProfile.setImage(UIImage(systemName: "person.circle"), for: .normal)
        btnProfile.tintColor = .darkGray
        //constraint
        btnProfile.translatesAutoresizingMaskIntoConstraints = false //contraint를 주기 위해서 false로 설정
        btnProfile.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        btnProfile.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnProfile.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnProfile.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        btnProfile.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 100).isActive = true
        // 클릭 이벤트
        btnProfile.addTarget(self, action: Selector("btnClicked:"), for: .touchUpInside)
        
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
        btnPlus.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110).isActive = true
        btnPlus.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
    }
    
    func btnClicked(_ sender: UIButton?) {
        
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
