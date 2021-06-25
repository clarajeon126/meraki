//
//  OpportunityDepthViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 2/1/21.
//

import UIKit

class OpportunityDepthViewController: UIViewController {

    var opportunity = Opportunity()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var basicInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = nil
        ImageService.getImage(withURL: opportunity.imageUrl) { (image, url) in
            self.imageView.image = image
        }
        mainTitle.text = opportunity.title
        subTitle.text = opportunity.subtitle
        basicInfo.text = opportunity.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = TimeZone.current
        
        let startDate = dateFormatter.string(from: opportunity.dateStart)
        let endDate = dateFormatter.string(from: opportunity.dateEnd)
        
        dateLabel.text = "\(startDate) to \(endDate)"
        
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
