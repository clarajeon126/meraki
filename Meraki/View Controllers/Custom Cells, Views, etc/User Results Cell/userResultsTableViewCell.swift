//
//  userResultsTableViewCell.swift
//  Meraki
//
//  Created by Clara Jeon on 2/16/21.
//

import UIKit

class userResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var firstLastNameLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    weak var userProfile: UserProfile?
    
    func set(userProfile: UserProfile) {
        self.userProfile = userProfile
        
        self.profilePhotoImageView.image = nil
        ImageService.getImage(withURL: userProfile.profilePhotoURL) { (image, url) in
            guard let _userProfile = self.userProfile else { return }
            if _userProfile.profilePhotoURL.absoluteString == url.absoluteString {
                self.profilePhotoImageView.image = image
            } else {
                print("Not the right Post Image")
            }
        }
        
        self.firstLastNameLabel.text = "\(userProfile.firstName) \(userProfile.lastName)"
        self.headlineLabel.text = userProfile.headline
    }
    
}
