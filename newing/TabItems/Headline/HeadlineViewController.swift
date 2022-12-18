//
//  HeadlineViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/04.
//

import UIKit
import Alamofire

class HeadlineViewController: BaseViewController {

    @IBOutlet weak var tvArticles: UITableView!
  
    
    var articles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHeader(type: 1)
        loadArticles()
    }
    
    func loadArticles(){
        let url = "https://newsapi.org/v2/top-headlines"
        let query = ["country": "us", "pageSize": 20, "page": 1] as [String : Any]
        let header: HTTPHeaders = ["X-Api-Key": "b0657dfc92ca47c487809bf6e1966745"]
        
        AF.request(url, method: .get, parameters: query, headers: header)
            .responseDecodable(completionHandler: { [weak self] (response: DataResponse<ArticleList, AFError>) in
                switch (response.result) {
                case .success(let data):
                    NSLog("data : \(data)")
                    self?.articles = data.articles
                    self?.tvArticles.reloadData()
                default:
                    NSLog("response: \(response)")
                }
            })
    }
}

extension HeadlineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headLineCell") as! HeadlineTableViewCell
        let article = articles[indexPath.row]
        let title = article.title
        let source = article.source?.name
        
        var date = article.publishedAt
        let endIdx: String.Index = date!.index(date!.startIndex, offsetBy: 9)
        date = String(date![...endIdx])
        
        let urlToImage = article.urlToImage
        
        cell.setup(title: title, urlToImage: urlToImage, source: source, date: date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let articleVC = self.storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as? ArticleViewController else { return }
        
        let article = articles[indexPath.row]
        articleVC.urlStr = article.url!
        articleVC.articleTitle = article.title!
        articleVC.source = (article.source?.name)!
        
        //date 형식에 맞춰 자르기
        var date = article.publishedAt
        let endIdx: String.Index = date!.index(date!.startIndex, offsetBy: 9)
        date = String(date![...endIdx])
        articleVC.date = date!
        
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        articleVC.modalPresentationStyle = .fullScreen
        self.present(articleVC, animated: false, completion: nil)
    }
   
}
struct ArticleList: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case description
        case url
        case urlToImage
        case publishedAt
        case content
    }
}

struct Source: Codable {
    let id: String?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
