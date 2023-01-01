
import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSource: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
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
        if let url, !url.isEmpty {
            ivImage.load(urlString: url)
        } else{
            // 기본이미지 로드
            ivImage.image = UIImage(named: "newing_logo")
        }
    }
}
