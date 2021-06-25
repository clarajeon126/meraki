//
//  CommentTableViewCell.swift
//  Meraki
//
//  Created by Clara Jeon on 2/10/21.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var firstLastNameLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var commentContentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.width / 1.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    weak var comment: Comment?
    
    func set(comment: Comment){
        self.comment = comment
        
        self.profilePhotoImageView.image = nil
        ImageService.getImage(withURL: comment.author.profilePhotoURL) { (image, url) in
            guard let _comment = self.comment else { return }
            
            self.profilePhotoImageView.image = image
        }
        firstLastNameLabel.text = "\(comment.author.firstName) \(comment.author.lastName)"
        headlineLabel.text = comment.author.headline
        commentContentLabel.text = comment.content
        timeLabel.text = comment.createdAt.calenderTimeSinceNow()
        
    }
    
}


