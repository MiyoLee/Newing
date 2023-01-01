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
    }
    
    func loadSavedArticles() {
        savedArticles.removeAll()
        
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
                                    self?.savedArticles.append(a!)
                                }
                            } catch {
                                print(error)
                            }
                        }
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
        articleVC.urlStr = article.url!
        articleVC.articleTitle = article.title!
        articleVC.source = (article.source?.name)!
        articleVC.dateStr = article.publishedAt!
        // 저장된 기사이므로 article객체 그대로 넘겨줌
        articleVC.isSaved = true
        articleVC.article = article
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        articleVC.modalPresentationStyle = .fullScreen
        self.present(articleVC, animated: false, completion: nil)
    }
    
    // 스와이프해서 삭제하기 시도..안됌
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let deleteAction = UIContextualAction(style: .destructive, title: "잘가시츄..") { (action, view, success ) in
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            // firestore에서 삭제하기
//            self.db.collection("saved_article").document(self.savedArticles[indexPath.row].documentId!).delete() { err in
//                if let err = err {
//                    print("Error removing document: \(err)")
//                } else {
//                    print("Document successfully removed!")
//                    self.savedArticles.remove(at: indexPath.row)
//                }
//            }
//        }
//        let config = UISwipeActionsConfiguration(actions: [deleteAction])
//        config.performsFirstActionWithFullSwipe = false
//        return config
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    // 스와이프해서 삭제하기
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            // firestore에서 삭제하기
//            db.collection("saved_article").document(savedArticles[indexPath.row].documentId!).delete() { err in
//                if let err = err {
//                    print("Error removing document: \(err)")
//                } else {
//                    print("Document successfully removed!")
//                }
//            }
//            savedArticles.remove(at: indexPath.row)
//
//        } else if editingStyle == .insert {
//
//        }
//    }
}
