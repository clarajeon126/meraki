//
//  OtherProfileViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 2/16/21.
//

import UIKit

class OtherProfileViewController: UIViewController {

    let postTableCellId = "postCell"
    
    var userPosts = [Post]()
    
    @IBOutlet weak var firstLastNameLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    @IBOutlet var questionLabels: [UILabel]!
    
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var aboutView: UIView!
    
    var userProfile = UserProfile()
    
    @IBOutlet weak var postTableView: UITableView!
    
    //outlets for the answer labels
    @IBOutlet weak var whoIsUserAnswerLabel: UILabel!
    @IBOutlet weak var merakiProjectAnswerLabel: UILabel!
    @IBOutlet weak var skillsAnswerLabel: UILabel!
    @IBOutlet weak var accomplishmentsAnswerLabel: UILabel!
    @IBOutlet weak var passionAnswerLabel: UILabel!
    
    @IBOutlet weak var containsAllAboutUserStackView: UIStackView!
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            aboutView.isHidden = false
            postView.isHidden = true
        }
        else {
            postView.isHidden = false
            aboutView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.register(UINib.init(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: postTableCellId)
        postTableView.dataSource = self
        postTableView.delegate = self
        postTableView.reloadData()
        
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.width /  2
        
        DatabaseManager.shared.getSpecificUserPost(uid: userProfile.uid) { (postArray) in
            self.userPosts.insert(contentsOf: postArray, at: 0)
            self.postTableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let userFirstName = userProfile.firstName
        
        for x in 0..<questionLabels.count {
            let questionInFocus = questionLabels[x]
            questionInFocus.text = questionInFocus.text?.replacingOccurrences(of: "User", with: userFirstName)
        }

        let userLastName = userProfile.lastName
        let userHeadline = userProfile.headline
        
        profilePhotoImageView.image = nil
        
        ImageService.getImage(withURL: userProfile.profilePhotoURL) { (userProfileImage, url) in
            self.profilePhotoImageView.image = userProfileImage
        }
        
        firstLastNameLabel.text = userFirstName + " " + userLastName
        headlineLabel.text = userHeadline
        
        uploadAboutUserData()
    }
    
    func uploadAboutUserData(){
        
        let currentUid = userProfile.uid
        
        DatabaseManager.shared.getAboutUser(uid: currentUid) { (aboutUser) in
            self.whoIsUserAnswerLabel.text = aboutUser.whoAreYou
            self.merakiProjectAnswerLabel.text = aboutUser.merakiProject
            self.skillsAnswerLabel.text = aboutUser.skills
            self.accomplishmentsAnswerLabel.text = aboutUser.accomplishments
            self.passionAnswerLabel.text = aboutUser.passion
            self.containsAllAboutUserStackView.isHidden = false
            
            self.postTableView.reloadData()
        }
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

extension OtherProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 400
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return userPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: postTableCellId, for: indexPath) as! PostTableViewCell
            cell.set(post: userPosts[indexPath.row])
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "myPostInDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "otherUserToPost" {
            let indexPath = postTableView.indexPathForSelectedRow
            let postInDepthVC = segue.destination as! PostDepthViewController
            postInDepthVC.postInQuestion = posts[indexPath!.row]
        }
    }
}

