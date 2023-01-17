//
//  FavoriteViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/04.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FavoriteViewController: BaseViewController {
        
//    var db: Firestore!
//    var savedArticlesRef: CollectionReference!
    @IBOutlet weak var tvFavorite: UITableView!
    
    var savedArticles: [Article] = []
    
    let myFirestore = MyFirestore()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHeader(type: 1)
        loadSavedArticles()
        
        // pull to refresh 세팅
        tvFavorite.refreshControl = UIRefreshControl()
        tvFavorite.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        tvFavorite.refreshControl?.endRefreshing()
        loadSavedArticles()
    }
    
    func loadSavedArticles() {
        var tmpSavedArticles: [Article] = []
        
        if let currentUserId = UserDefaults.standard.string(forKey: "userId"), !currentUserId.isEmpty {
            db.collection("saved_article").whereField("userId", isEqualTo: currentUserId).order(by: "dateTime", descending: true)
                .getDocuments() { [weak self] (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
    //                        print("\(document.documentID) => \(document.data())")
                            var a: Article? = nil
                            do {
                                a = try document.data(as: Article.self)
                                a?.documentId = document.documentID
                                if a != nil {
                                    tmpSavedArticles.append(a!)
                                }
                            } catch {
                                print(error)
                            }
                        }
                        self?.savedArticles = tmpSavedArticles
                        self?.tvFavorite.reloadData()
                    }
            }
        } else {
            print("Not logged in.")
            tvFavorite?.reloadData()
        }
    }
    
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as! FavoriteTableViewCell
        let article = savedArticles[indexPath.row]
        let title = article.title
        let source = article.source?.name
        let dateStr = article.publishedAt
        
        let urlToImage = article.urlToImage
        
        cell.setup(title: title, urlToImage: urlToImage, source: source, date: dateStr)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let articleVC = self.storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as? ArticleViewController else { return }
        
        let article = savedArticles[indexPath.row]
        articleVC.isSaved = true
        articleVC.documentId = article.documentId
        
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        articleVC.modalPresentationStyle = .fullScreen
        self.present(articleVC, animated: false, completion: nil)
    }
}
