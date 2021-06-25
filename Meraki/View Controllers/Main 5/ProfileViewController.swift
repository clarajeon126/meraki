//
//  ProfileViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 1/27/21.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var myPosts = [Post]()
    let postTableCellId = "postCell"
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var myPostTableView: UITableView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userHeadlineLabel: UILabel!
    @IBOutlet weak var postsView: UIView!
    @IBOutlet weak var aboutView: UIView!
    

    @IBOutlet var evenViews: [UIView]!
    
    //outlets for the answer labels
    @IBOutlet weak var whoIsUserAnswerLabel: UILabel!
    @IBOutlet weak var merakiProjectAnswerLabel: UILabel!
    @IBOutlet weak var skillsAnswerLabel: UILabel!
    @IBOutlet weak var accomplishmentsAnswerLabel: UILabel!
    @IBOutlet weak var passionAnswerLabel: UILabel!
    
    //outlet collection for question labels
    @IBOutlet var questionLabels: [UILabel]!
    
    @IBOutlet weak var containsAllAboutUserStackView: UIStackView!
    
    @IBOutlet weak var addToBioButton: UIButton!
    
    @IBAction func segmentControllerChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            aboutView.isHidden = false
            postsView.isHidden = true
        }
        else {
            postsView.isHidden = false
            aboutView.isHidden = true
        }
    }
    @IBAction func botTapped(_ sender: Any) {
        KommunicateManager.shared.openBotChat(vc: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //border and color design for every other view
        for x in 0..<evenViews.count {
            let oneInFocus = evenViews[x]
            
            oneInFocus.layer.cornerRadius = 15
            oneInFocus.layer.borderWidth = 1
            oneInFocus.layer.borderColor = mainColor.cgColor
        }
        
        guard let userFirstName = UserProfile.currentUserProfile?.firstName else {
            return
        }
        
        for x in 0..<questionLabels.count {
            let questionInFocus = questionLabels[x]
            questionInFocus.text = questionInFocus.text?.replacingOccurrences(of: "User", with: userFirstName)
        }
        
        
        //put user data about themselves to the respective labels
        uploadAboutUserData()
        
        
        
        myPostTableView.register(UINib.init(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: postTableCellId)
        myPostTableView.dataSource = self
        myPostTableView.delegate = self
    

        myPostTableView.reloadData()
        print(myPostTableView.numberOfRows(inSection: 0))
        profileImage.layer.cornerRadius = profileImage.frame.width /  2
        
        DatabaseManager.shared.getUserPost(completion: { [self] (postArray) in
            self.myPosts.insert(contentsOf: postArray, at: 0)
            self.myPostTableView.reloadData()
            print("myPosts array in profile\(myPosts)")
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        let userFirstName = UserProfile.currentUserProfile?.firstName ?? "Jane"
        let userLastName = UserProfile.currentUserProfile?.lastName ?? "Doe"
        let userHeadline = UserProfile.currentUserProfile?.headline ?? "Your Headline..."
        profileImage.image = nil
        ImageService.getImage(withURL: UserProfile.currentUserProfile!.profilePhotoURL) { (userProfileImage, url) in
            self.profileImage.image = userProfileImage
        }
        userName.text = userFirstName + " " + userLastName
        userHeadlineLabel.text = userHeadline
    }
    
    func uploadAboutUserData(){
        
        guard let currentUid = UserProfile.currentUserProfile?.uid else {
            return
        }
        DatabaseManager.shared.getAboutUser(uid: currentUid) { (aboutUser) in
            self.whoIsUserAnswerLabel.text = aboutUser.whoAreYou
            self.merakiProjectAnswerLabel.text = aboutUser.merakiProject
            self.skillsAnswerLabel.text = aboutUser.skills
            self.accomplishmentsAnswerLabel.text = aboutUser.accomplishments
            self.passionAnswerLabel.text = aboutUser.passion
            self.containsAllAboutUserStackView.isHidden = false
            self.addToBioButton.isHidden = true
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 400
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return myPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: postTableCellId, for: indexPath) as! PostTableViewCell
            cell.set(post: myPosts[indexPath.row])
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "myPostInDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myPostInDetailSegue" {
            let indexPath = myPostTableView.indexPathForSelectedRow
            let postInDepthVC = segue.destination as! PostDepthViewController
            postInDepthVC.postInQuestion = myPosts[indexPath!.row]
            /*postInDepthVC.postTitle = postAtIndex.title
            postInDepthVC.firstLastName = postAtIndex.author.firstName + " " + postAtIndex.author.lastName
            postInDepthVC.headline = postAtIndex.author.headline
            postInDepthVC.content = postAtIndex.content
            postInDepthVC.postId = postAtIndex.id
            
            ImageService.getImage(withURL: postAtIndex.author.profilePhotoURL) { image, url in
                postInDepthVC.profilePhoto = image!

            }
            
            ImageService.getImage(withURL: postAtIndex.image) { image, url in
                let _post = postAtIndex
                if _post.image.absoluteString == url.absoluteString {
                    postInDepthVC.postImage = image!
                } else {
                    print("Not the right image")
                }
            }*/
        }
    }
}
