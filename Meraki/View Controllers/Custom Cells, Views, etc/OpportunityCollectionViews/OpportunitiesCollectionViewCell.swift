//
//  OpportunitiesCollectionViewCell.swift
//  Meraki
//
//  Created by Clara Jeon on 2/15/21.
//

import UIKit

class OpportunitiesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 15
    }
    
    weak var opportunity: Opportunity?
    
    func set(opportunity: Opportunity) {
        self.opportunity = opportunity
        
        self.imageView.image = nil
        ImageService.getImage(withURL: opportunity.imageUrl) { (image, url) in
            guard let _opportunity = self.opportunity else {
                return
            }
            if _opportunity.imageUrl.absoluteString == url.absoluteString {
                self.imageView.image = image
            } else {
                print("Not the right Post Image")
            }
        }
        
        mainTitle.text = opportunity.title
        subTitle.text = opportunity.subtitle
        category.text = opportunity.category
    }

}
