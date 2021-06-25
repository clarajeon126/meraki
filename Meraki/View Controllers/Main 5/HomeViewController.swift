//
//  ViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 1/27/21.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

public var posts = [Post]()

class HomeViewController: UIViewController {
    
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var postTableView: UITableView!
    
    let postTableCellId = "postCell"
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
        postTableView.register(UINib.init(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: postTableCellId)
        
        postTableView.dataSource = self
        postTableView.delegate = self

        postTableView.reloadData()
        
        refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            postTableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            postTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        handleRefresh()
        
        
    }
    @IBAction func botTapped(_ sender: Any) {
        KommunicateManager.shared.openBotChat(vc: self)
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        handleNotAuthenticated()
        
        let userName = UserProfile.currentUserProfile?.firstName ?? "yourself"
        introductionLabel.text = "Meraki: to put something of " + userName + " into your work"
        
    }
    
    @objc func handleRefresh() {
        DatabaseManager.shared.arrayOfPostByTime { (postArray) in
            posts = postArray
            self.postTableView.reloadData()
        }
        refreshControl.endRefreshing()
    }
    

    
    
    //handleing not authenticated
    private func handleNotAuthenticated() {
        if Auth.auth().currentUser == nil {
            let startingStoryBoard = UIStoryboard(name: "Starting", bundle: nil)
            let loginVC = startingStoryBoard.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false, completion: nil)
        }
        else{
            print("elseobserve\(Auth.auth().currentUser!.uid)")
            DatabaseManager.shared.observeUserProfile(Auth.auth().currentUser!.uid) { (userProfile) in
                UserProfile.currentUserProfile = userProfile
                KommunicateManager.shared.registerUser()
            }
        }
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    //height for each row
    func tableView(_ tatbleView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    //number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    //putting cell where the info on each post will be put in
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postTableCellId, for: indexPath) as! PostTableViewCell
        cell.set(post: posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "postInDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postInDetailSegue" {
            let indexPath = postTableView.indexPathForSelectedRow
            let postInDepthVC = segue.destination as! PostDepthViewController
            let postAtIndex:Post = posts[indexPath!.row]
            postInDepthVC.postInQuestion = posts[indexPath!.row]
        }
    }
}
