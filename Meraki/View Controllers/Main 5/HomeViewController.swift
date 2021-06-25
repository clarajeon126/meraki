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
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching:CGFloat = 3.0
    var lastUploadedPostID:String?
    
    var refreshControl:UIRefreshControl!
    
    var postsRef:DatabaseReference {
        return Database.database().reference().child("posts")
    }
    
    var oldPostsQuery:DatabaseQuery {
        print("in old post query")
        var queryRef:DatabaseQuery
        let lastPost = posts.last
        if lastPost != nil {
            let lastTimestamp = lastPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }
    
    var newPostsQuery:DatabaseQuery {
        var queryRef:DatabaseQuery
        let firstPost = posts.first
        if firstPost != nil {
            let firstTimestamp = firstPost!.createdAt.timeIntervalSince1970 * 1000
            print("in new post query")
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: firstTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
        postTableView.register(UINib.init(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: postTableCellId)
        postTableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        
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
        
        beginBatchFetch()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        handleNotAuthenticated()
        
        let userName = UserProfile.currentUserProfile?.firstName ?? "yourself"
        introductionLabel.text = "Meraki: to put something of " + userName + " into your work"
        
        listenForNewPosts()
    }
    @objc func handleRefresh() {
        print("Refresh!")
        
        newPostsQuery.queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
            let firstPost = posts.first
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String:Any],
                   childSnapshot.key != firstPost?.id{
                    Post.parse(key: childSnapshot.key, data: data, completion: { (post) in
                        print("\(tempPosts)tempPostssssinNewPostQuery")
                        tempPosts.insert(post, at: 0)
                        
                        posts.insert(contentsOf: tempPosts, at: 0)
                        
                        let newIndexPaths = (0..<tempPosts.count).map { i in
                            return IndexPath(row: i, section: 0)
                        }
                        
                        self.refreshControl.endRefreshing()
                        self.postTableView.insertRows(at: newIndexPaths, with: .top)
                        self.postTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        
                        self.listenForNewPosts()
                    })
                }
            }
            
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            
            if !fetchingMore && !endReached {
                print("posts before batch fetch: \(posts)")
                beginBatchFetch()
                print("posts after batch fetch: \(posts)")
            }
        }
    }
    
    func fetchPosts(completion:@escaping (_ posts:[Post])->()) {
        
        oldPostsQuery.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
            var numOfChildThroughFor = 0
            let lastPost = posts.last
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    childSnapshot.key != lastPost?.id{
                    Post.parse(key: childSnapshot.key, data: data, completion: { (post) in
                        numOfChildThroughFor += 1
                        print("fetchPosts\(post)")
                        tempPosts.insert(post, at: 0)
                        if numOfChildThroughFor == snapshot.childrenCount {
                            return completion(tempPosts)
                        }
                        print("inside fetch posts temp posts: \(tempPosts)")
                    })
                }
            }
        })
    }
    
    func beginBatchFetch() {
        fetchingMore = true
        self.postTableView.reloadSections(IndexSet(integer: 1), with: .fade)
        
        fetchPosts { newPosts in
            posts.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.count == 0
            UIView.performWithoutAnimation {
                print("POSTSSSSS")
                self.postTableView.reloadData()
                
                print("above listen for new posts")
                self.listenForNewPosts()
            }
        }
    }
    
    var postListenerHandle:UInt?
    
    func listenForNewPosts() {
        
        guard !fetchingMore else { return }
        
        // Avoiding duplicate listeners
        stopListeningForNewPosts()
        
        postListenerHandle = newPostsQuery.observe(.childAdded, with: { snapshot in
            print(snapshot.key)
            if snapshot.key != posts.first?.id,
               let data = snapshot.value as? [String:Any] {
                Post.parse(key: snapshot.key, data: data) { (post) in
                    self.stopListeningForNewPosts()
                    
                    if snapshot.key == self.lastUploadedPostID {
                        self.handleRefresh()
                        self.lastUploadedPostID = nil
                    } else {
                       //self.toggleSeeNewPostsButton(hidden: false)
                    }
                }
            }
        })
    }
    
    func stopListeningForNewPosts() {
        if let handle = postListenerHandle {
            newPostsQuery.removeObserver(withHandle: handle)
            postListenerHandle = nil
        }
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
                
            }
        }
    }


}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    //height for each row
    func tableView(_ tatbleView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    //number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return posts.count
        case 1:
            return fetchingMore ? 1 : 0
        default:
            return 0
        }
    }
    
    //putting cell where the info on each post will be put in
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: postTableCellId, for: indexPath) as! PostTableViewCell
            cell.set(post: posts[indexPath.row])
            print("YEEEETTTTTT")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
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
            /*postInDepthVC.postTitle = postAtIndex.title
            postInDepthVC.firstLastName = postAtIndex.author.firstName + " " + postAtIndex.author.lastName
            postInDepthVC.headline = postAtIndex.author.headline
            postInDepthVC.content = postAtIndex.content
            postInDepthVC.postId = postAtIndex.id
            
            ImageService.getImage(withURL: postAtIndex.author.profilePhotoURL) { image, url in
                let _post = postAtIndex
                if _post.image.absoluteString == url.absoluteString {
                    postInDepthVC.profilePhoto = image!
                } else {
                    print("Not the right image")
                }
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
extension HomeViewController: NewPostVCDelegate {
    func didUploadPost(withID id: String) {
        self.lastUploadedPostID = id
        print(id)
    }
}

