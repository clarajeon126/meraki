//
//  AboutUserTableViewCell.swift
//  Meraki
//
//  Created by Clara Jeon on 2/12/21.
//

import UIKit

class AboutUserTableViewCell: UITableViewCell {

    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerContentLabel: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewBackground.layer.cornerRadius = viewBackground.frame.width * 0.1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(question: String, answer: String){
        self.questionTitleLabel.text = question
        self.answerContentLabel.text = answer
    }
    
}
