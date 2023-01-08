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
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSource: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var viewContentWrapper: UIView!
    @IBOutlet weak var tvMemo: UITextView!
    
    var isSaved: Bool = false   // 이 뉴스가 저장된 뉴스인지?
    var documentId: String?     // documentId. 저장된 뉴스일 경우 존재함.
    
    var userId: String?
    var urlStr: String = ""
    var articleTitle: String = ""
    var source: String = ""
    var date: Date?
    var dateStr: String = ""
    var article: Article? = nil
    let textViewPlaceHolder = "Please leave a note.\n- What do you think of this article?\n- What did you learn from this article?"
    
    let myFirestore = MyFirestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardObserver()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    func setup() {
        setupView()
        setupArticle()
    }
    
    func setupView() {
        addHeader(type: 2)
        // set floating button
        if isSaved {
            addBtnMemo()
        } else {
            addBtnPlus()
        }
        // set content view
        viewContentWrapper.layer.cornerRadius = ivImage.frame.width/16
        viewContentWrapper.clipsToBounds = true
        
        // set memo view
        tvMemo.textContainerInset = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        tvMemo.isHidden = true
    }
    
    func setupArticle() {
        if isSaved && (documentId != nil) {  // 저장된 기사일 경우, documentId로 article 불러오기.
            loadSavedArticle(documentId!)
        } else {    // 새로 불러오는 기사일 경우.
            userId = UserDefaults.standard.object(forKey: "userId") as? String
            loadArticle()
        }
    }
    
    func loadSavedArticle(_ documentId: String) {
        myFirestore.getArticle(documentId, completion: { [weak self] document, err in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                do {
                    self?.article = try document.data(as: Article.self)
                    self?.article?.documentId = document.documentID
                    if self?.article != nil {
                        self?.setDataExceptContent()
                        self?.lbContent.text = self?.article?.content
                    }
                } catch {
                    print(error)
                }
            } else {
                print("Document does not exist")
            }
        })
    }
    
    func loadArticle() {
        if let articleUrl = URL(string: urlStr) {
            //ReadabilityKit 사용. title, image, date 불러옴
            Readability.parse(url: articleUrl, completion: { [weak self] data in
                self?.article = Article(userId: self?.userId, title: data?.title, source: self?.source, date: data?.datePublished, url: self?.urlStr, urlToImage: data?.topImage, content: "")
                self?.setDataExceptContent()
            })
            
            //UntaggerManager 사용. content 불러옴
            UntaggerManager.sharedInstance.getText(url: articleUrl) { [weak self] (title, body, source, error) in
                if error == nil {
                    //컨텐츠 article 객체에 set
                    if let body = body, !body.isEmpty{
                        self?.article?.content = body  // article 객체에 content set.
                        self?.lbContent.text = body
                    }
                }
                if let error = error {
                    print("Error: \(error.message)")
                }
            }
        }
    }
    
    // article 객체에 저장된 데이터들을 뉴스 데이터 화면에 뿌리기
    func setDataExceptContent() {
        //이미지 세팅
        if let imgUrl = article!.urlToImage {
            ivImage.load(urlString: imgUrl)
        }
        
        //타이틀,날짜,출처,컨텐츠,메모 세팅
        lbTitle.text = article!.title

        if let date = article!.publishedAt {
            lbDate.text = date
        }
        
        lbSource.text = article!.source?.name
        
        //메모 세팅
        tvMemo.text = article!.userMemo
        if tvMemo.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || tvMemo.text == textViewPlaceHolder {
            tvMemo.text = textViewPlaceHolder
            tvMemo.textColor = .gray
        } else {
            tvMemo.textColor = .black
        }
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
        if let userId = UserDefaults.standard.object(forKey: "userId") as? String, !userId.isEmpty {   // 로그인 상태라면
            // db에 article 저장하기
            if let arti = article {
                myFirestore.saveArticle(arti) { error in
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
                print("[btnPlusClicked()] article is nil!")
            }
        } else {    // 미로그인 상태라면
            
            // 로그인 페이지로 이동
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnMemoClicked(_ sender: Any) {
        if !tvMemo.isHidden {   // 메모장 떠있는 상태에서 플로팅 버튼 눌렀을 경우
            tapBackgroundView(sender)
            saveMemo()
        }
        tvMemo.isHidden = !tvMemo.isHidden
    }
    
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
        // firestore에 저장하기
    }
    
    func saveMemo() {
        if article != nil && article!.documentId != nil && tvMemo.text != article!.userMemo {
            //article!.userMemo = tvMemo.text
            myFirestore.updateArticle(article!.documentId!, ["userMemo" : tvMemo.text]){ error in
                if error == nil {
                    print("memo update successed")
                } else {
                    print("memo update failed: \(String(describing: error))")
                }
            }
        } else {
            print("[saveMemo()] article is nil!")
        }
    }

    
}

extension ArticleViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder && textView.textColor != .black {   //회색으로 적힌 placeholder라면
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .gray
        }
    }
    
    
}
