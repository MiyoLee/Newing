//
//  ArticleViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/12/12.
//

import UIKit
import Alamofire
import ReadabilityKit
import Untagger

class ArticleViewController: BaseViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSource: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lbContent: UILabel!
    
    var urlStr: String = ""
    var articleTitle: String = ""
    var source: String = ""
    var date: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBtnBack()
        addBtnPlus()
        loadArticle()
    }
    
    func loadArticle() {
        
        //ReadabilityKit 사용
        let articleUrl = URL(string: urlStr)!
        Readability.parse(url: articleUrl, completion: { data in
            let title = data?.title
            //let description = data?.description
            //let keywords = data?.keywords
            let imageUrl = data?.topImage
            //let videoUrl = data?.topVideo
            let datePublished = data?.datePublished
            
            self.setDataExceptContent(title: title, imgUrl: imageUrl, date: datePublished)   //컨텐츠 제외한 데이터 화면에 뿌리기
            
        })
        
        //UntaggerManager 사용
        UntaggerManager.sharedInstance.getText(url: articleUrl) { (title, body, source, error) in
            if error == nil {
                self.lbContent.text = body  //컨텐츠 set
            }
            
            if let error = error {
                print("Error: \(error.message)")
            }
        }
    }
    
    func setDataExceptContent(title: String?, imgUrl: String?, date: String?) {
        //이미지 세팅
        if let imgUrl {
            ivImage.load(urlString: imgUrl)
        }
        ivImage.layer.cornerRadius = ivImage.frame.width/16
        ivImage.clipsToBounds = true
        
        //타이틀, 날짜, 출처 세팅
        lbTitle.text = title
        if let date {
            lbDate.text = date
        } else {
            lbDate.text = self.date
        }
        lbSource.text = source
        
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton?) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
