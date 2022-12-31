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
import FirebaseFirestore

class ArticleViewController: BaseViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSource: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var viewContentWrapper: UIView!
    
    var userId: String?
    
    var urlStr: String = ""
    var articleTitle: String = ""
    var source: String = ""
    var date: Date?
    var dateStr: String = ""
    var article: Article? = nil
    
    let myFirestore = MyFirestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadArticle()
        print("loadArticleFinished")
    }
    
    func setup() {
        setupView()
        setupArticle()
    }
    
    func setupView() {
        addHeader(type: 2)
        addBtnPlus()
        viewContentWrapper.layer.cornerRadius = ivImage.frame.width/16
        viewContentWrapper.clipsToBounds = true
    }
    
    func setupArticle() {
        userId = UserDefaults.standard.object(forKey: "userId") as? String
        article = Article(userId: userId, title: articleTitle, source: source, date: dateStr, url: urlStr, urlToImage: "", content: "")
    }
    
    func loadArticle() {
        if let articleUrl = URL(string: urlStr) {
            //ReadabilityKit 사용. title, image, date 불러옴
            Readability.parse(url: articleUrl, completion: { data in
                let title = data?.title
                //let description = data?.description
                //let keywords = data?.keywords
                let imageUrl = data?.topImage
                //let videoUrl = data?.topVideo
                let datePublished = data?.datePublished
                
                // article 객체에 title, imageUrl set.
                self.article?.title = title
                self.article?.urlToImage = imageUrl

                self.setDataExceptContent(title: title, imgUrl: imageUrl, date: datePublished)   //컨텐츠 제외한 데이터 화면에 뿌리기
                
            })
            
            //UntaggerManager 사용. content 불러옴
            UntaggerManager.sharedInstance.getText(url: articleUrl) { (title, body, source, error) in
                if error == nil {
                    //컨텐츠 set
                    if let body = body, !body.isEmpty{
                        self.article?.content = body  // article 객체에 content set.
                        self.lbContent.text = body
                    } else {
                        self.lbContent.text = "No content"
                    }
                }
                
                if let error = error {
                    print("Error: \(error.message)")
                }
            }
        }
    }
    
    func setDataExceptContent(title: String?, imgUrl: String?, date: String?) {
        //이미지 세팅
        if let imgUrl {
            ivImage.load(urlString: imgUrl)
        }
        
        //타이틀, 날짜, 출처 세팅
        lbTitle.text = title
        if let date {
            lbDate.text = date
        } else {
            lbDate.text = self.dateStr
        }
        lbSource.text = source
        
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton?) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnGoLinkClicked(_ sender: Any) {
        if let articleUrl = URL(string: urlStr) {
            UIApplication.shared.open(articleUrl)
        }
            
    }
    
    @IBAction func btnPlusClicked(_ sender: Any) {
        // db에 article 저장하기
        if let arti = article {
            myFirestore.save(arti) { error in
                if error == nil {
                    // confirm 띄우기
                    self.popConfirm(title: "Added to Favorite.", message: "Would you like to go to the Favorite tab?") {
                        
                        // favorite 탭으로 이동, 현재 화면 닫기
                        if let tvc = self.presentingViewController as? UITabBarController {
                            if let vcs = tvc.viewControllers, !vcs.isEmpty {
                                tvc.selectedIndex = 1
                                // tvc.selectedViewController 새로고침 해야됌
                                if let vc = tvc.selectedViewController as? FavoriteViewController {
                                    vc.loadSavedArticles()
                                }
                                self.dismiss(animated: false)
                            }
                        }
                        
                    }
                } else {
                    print("error: \(String(describing: error))")
                }
            }
        } else {
            print("article is nil!")
        }
        
    }
}
