//
//  PostDepthViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 2/1/21.
//

import UIKit

class PostDepthViewController: UIViewController {

    var postInQuestion = Post()
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var userFirstLastNameLabel: UILabel!
    
    @IBOutlet weak var headlineLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var overallImageView: UIImageView!

    
    @IBOutlet weak var commentsTableView: UITableView!

    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.register(UINib.init(nibName: "SelfCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "selfCommentCell")
        commentsTableView.register(UINib.init(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentCellId")
        
        self.profilePhotoImageView.image = nil
        ImageService.getImage(withURL: postInQuestion.author.profilePhotoURL) { (profileImage, url) in
            self.profilePhotoImageView.image = profileImage
        }
        
        //self.profilePhotoImageView.image =
        self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.width / 2
        self.titleLabel.text = postInQuestion.title
        self.userFirstLastNameLabel.text = "\(postInQuestion.author.firstName) \(postInQuestion.author.lastName)"
        self.headlineLabel.text = postInQuestion.author.headline
        self.contentLabel.text = postInQuestion.content
        self.overallImageView.image = nil
        ImageService.getImage(withURL: postInQuestion.image) { (postImage, url) in
            self.overallImageView.image = postImage
        }
    
        //setting up comments table view
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.reloadData()
        
        updateCommentArrayAndTableView()
    }
    public func updateCommentArrayAndTableView(){
        DatabaseManager.shared.createCommentArrayForPost(postId: postInQuestion.id) { (commentArray) in
            self.comments.removeAll()
            self.comments.insert(contentsOf: commentArray, at: 0)
            print(self.comments)
            self.commentsTableView.reloadData()
            print("inserted to major array")
        }
    }
}

extension PostDepthViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = commentsTableView.dequeueReusableCell(withIdentifier: "selfCommentCell") as! SelfCommentTableViewCell
            cell.postId = postInQuestion.id
            cell.postButton.addTarget(self, action: #selector(postTapped(_:)), for: .touchUpInside)
            return cell
        }
        else {
            let cell = commentsTableView.dequeueReusableCell(withIdentifier: "commentCellId") as! CommentTableViewCell
            cell.set(comment: comments[indexPath.row])
            return cell
        }
    }
    @objc func postTapped(_ sender: UIButton){
        updateCommentArrayAndTableView()
    }
}

