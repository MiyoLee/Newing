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
        
        // pull to refresh 세팅
        tvArticles.refreshControl = UIRefreshControl()
        tvArticles.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        tvArticles.refreshControl?.endRefreshing()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeadLineCell") as! HeadlineTableViewCell
        var article = articles[indexPath.row]
        let title = article.title
        let source = article.source?.name
        var dateStr = article.publishedAt
        
        // date 형식 변경 start
        let strategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)T\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)\(timeZone: .iso8601(.short))", timeZone: .current)
        let date = try? Date(article.publishedAt!, strategy: strategy)  // string to date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        if date != nil {
            dateStr = dateFormatter.string(from: date!)   // date to string
        }
        
        articles[indexPath.row].publishedAt = dateStr // set publishedAt
        // date 형식 변경 end
        
        let urlToImage = article.urlToImage
        
        cell.setup(title: title, urlToImage: urlToImage, source: source, date: dateStr)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let articleVC = self.storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as? ArticleViewController else { return }
        
        let article = articles[indexPath.row]
        articleVC.urlStr = article.url!
        articleVC.articleTitle = article.title!
        articleVC.source = (article.source?.name)!
        articleVC.dateStr = article.publishedAt!
        
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
