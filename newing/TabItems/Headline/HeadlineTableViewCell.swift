//
//  HeadlineTableViewCell.swift
//  newing
//
//  Created by Miyo Lee on 2022/10/09.
//

import UIKit
import Kingfisher

class HeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbSource: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(title: String?, urlToImage: String?, source: String?, date: String?){
        loadImage(url: urlToImage)
        
        ivImage.layer.cornerRadius = ivImage.frame.width/8
        ivImage.clipsToBounds = true
        
        lbTitle.text = title
        lbSource.text = source
        lbDate.text = date
    }
    
    func loadImage(url: String?){
        if let url{
            ivImage.load(urlString: url)
        } else{
            // 기본이미지 로드
        }
    }
}
