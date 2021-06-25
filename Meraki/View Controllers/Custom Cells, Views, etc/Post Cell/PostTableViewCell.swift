//
//  PostTableViewCell.swift
//  Meraki
//
//  Created by Clara Jeon on 2/4/21.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userHeadlineLabel: UILabel!
    @IBOutlet weak var titleOfPostLabel: UILabel!
    @IBOutlet weak var contentOfPostLabel: UILabel!
    @IBOutlet weak var imageOfContent: UIImageView!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userProfileImage.layer.cornerRadius = userProfileImage.frame.width / 1.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    weak var post:Post?
    
    func set(post:Post) {
        self.post = post
        
        self.userProfileImage.image = nil
        ImageService.getImage(withURL: post.author.profilePhotoURL) { image, url in
            guard let _post = self.post else { return }
            self.userProfileImage.image = image
            
        }
        
        self.imageOfContent.image = nil
        ImageService.getImage(withURL: post.image) { (imageOfPost, url) in
            guard let _post = self.post else { return }
            if _post.image.absoluteString == url.absoluteString {
                self.imageOfContent.image = imageOfPost
            } else {
                print("Not the right Post Image")
            }
        }
        self.commentCountLabel.text = "0 comments"
        DatabaseManager.shared.getNumberOfCommentsOnPost(postId: post.id) { (numOfComments) in
            print("num comments")
            print(numOfComments)
            self.commentCountLabel.text = "\(numOfComments) Comments"
        }
        
        userNameLabel.text = post.author.firstName + " " + post.author.lastName
        userHeadlineLabel.text = post.author.headline
        titleOfPostLabel.text = post.title
        contentOfPostLabel.text = post.content
        timeLabel.text = post.createdAt.calenderTimeSinceNow()
    }
    
}
