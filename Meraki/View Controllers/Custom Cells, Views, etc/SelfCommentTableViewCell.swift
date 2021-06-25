//
//  SelfCommentTableViewCell.swift
//  Meraki
//
//  Created by Clara Jeon on 2/11/21.
//

import UIKit

class SelfCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var firstLastNameLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    var postId = String()
    
    @IBOutlet weak var postButton: UIButton!
    @IBAction func postButtonTapped(_ sender: Any) {
        commentTextField.resignFirstResponder()
        
        guard let commentContent = commentTextField.text, !commentContent.isEmpty else {
            return
        }
        commentTextField.text = " "
        
        DatabaseManager.shared.insertComments(postId: postId, content: commentContent)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.width / 1.5
        
        self.profilePhotoImageView.image = nil
        ImageService.getImage(withURL: UserProfile.currentUserProfile!.profilePhotoURL) { (image, url) in
            self.profilePhotoImageView.image = image
        }
        
        let firstNameCommentor = UserProfile.currentUserProfile?.firstName ?? "First"
        let lastNameCommentor = UserProfile.currentUserProfile?.lastName ?? "Last"
        firstLastNameLabel.text = "\(firstNameCommentor) \(lastNameCommentor)"
        
        headlineLabel.text = UserProfile.currentUserProfile?.headline
        commentTextField.returnKeyType = .done
        commentTextField.delegate = self
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SelfCommentTableViewCell: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == commentTextField {
            commentTextField.resignFirstResponder()
        }
        return true
    }
}
