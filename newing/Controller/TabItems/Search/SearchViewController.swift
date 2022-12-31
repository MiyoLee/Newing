//
//  ViewController.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/04.
//

import UIKit
import Alamofire
import AlamofireRSSParser

class SearchViewController: BaseViewController {
    
    @IBOutlet weak var tvSearch: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnPlus: UIButton!
    
    var articles : [RSSItem] = []
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHeader(type: 1)
    }
    
    func loadData(){
        if let keyword = tfSearch.text{
            let encryptedKeyword = keyword.replacingOccurrences(of: " ", with: "%20")
            guard let url = URL(string: "https://news.google.com/rss/search?hl=en-US&gl=US&ceid=US:en&q=" + encryptedKeyword) else {return}
            loadRss(url);
        }
        //검색어 입력 되지 않음
    }
    
    func loadRss(_ url: URL){
        //        // XmlParserManager instance/object/variable.
        //        let myParser : XmlParserManager = XmlParserManager().initWithURL(data) as! XmlParserManager
        //
        //        // Put feed in array.
        //        rssFeed = myParser.feeds
        //        tvSearch.reloadData()
        
        //        AF.request(url).responseRSS() { (response) -> Void in
        //            if let feed: RSSFeed = response.value {
        //                // Do something with your new RSSFeed object!
        //                self.articles = feed.items
        //                for item in feed.items {
        //                    print(item)
        //                }
        //                self.tvSearch.reloadData()
        //            }
        //        }
        
        // Swift concurrency example.
        if #available(iOS 13.0, *) {
            Task.init {
                if let rss = await self.swiftConcurrencyFetch(url) {
                    print(rss)
                    if !rss.items.isEmpty {
                        self.articles = rss.items
                        self.tvSearch.reloadData()
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tvSearch.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        }
    }
    
    
    @available(iOS 13, *)
    func swiftConcurrencyFetch(_ url: URL) async -> RSSFeed? {
        let rss = await AF.request(url).serializingRSS().response.value
        return rss
    }
    
    @IBAction func btnSearchTouched(_ sender: Any) {
        if let text = tfSearch.text, !text.isEmpty {
            loadData()
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
        let item = articles[indexPath.row]
        let title = item.title
        let link = item.link
        let source = item.source
        
        //date to string
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "dd MMM yyyy"
        let date = dateFormatter.string(from: item.pubDate!)
       
        
        cell.setup(query: tfSearch.text, title: title, link: link, source: source, date: date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let articleVC = self.storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as? ArticleViewController else { return }
        
        let article = articles[indexPath.row]
        articleVC.urlStr = article.link!
        articleVC.articleTitle = article.title!
        articleVC.source = article.source!
        articleVC.date = article.pubDate
        //date to string
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateStr = dateFormatter.string(from: article.pubDate!)
        articleVC.dateStr = dateStr
        
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        articleVC.modalPresentationStyle = .fullScreen
        self.present(articleVC, animated: false, completion: nil)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loadData()
        return true
    }
}
