//
//  SearchTableViewCell.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/10.
//

import UIKit
import SwiftSoup

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSource: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(query: String?, title: String?, link: String?, source: String?, date: String?){
        lbSource.text = source
        lbDate.text = date
        
        if let titleText = title, let queryText = query {
           
            // myLabel의 text로 NSMutableAttributedString 인스턴스를 만들어줍니다.
            let attributeString = NSMutableAttributedString(string: titleText)

            // NSMutableAttributedString에 속성을 추가합니다.
            // 현재 추가한 속성은 queryText(검색어)만 System indigo 색으로 바꾼다! 입니다.
            attributeString.addAttribute(.foregroundColor, value: UIColor.systemIndigo, range: (titleText as NSString).range(of: queryText, options: .caseInsensitive))
            
            // Label에 방금 만든 속성을 적용합니다.
            self.lbTitle.attributedText = attributeString
        }
    }
    
}

