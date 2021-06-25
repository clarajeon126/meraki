//
//  DiscoverViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 1/27/21.
//

import UIKit

class DiscoverViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userResultsTableView: UITableView!
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            userResultsTableView.isHidden = false
            searchLabel.isHidden = true
            opportunityResultCollectionView.isHidden = true
            postTableView.isHidden = true
        }
        else if sender.selectedSegmentIndex == 1{
            userResultsTableView.isHidden = true
            searchLabel.isHidden = true
            opportunityResultCollectionView.isHidden = true
            postTableView.isHidden = false
        }
        else if sender.selectedSegmentIndex == 2{
            userResultsTableView.isHidden = true
            searchLabel.isHidden = true
            opportunityResultCollectionView.isHidden = false
            postTableView.isHidden = true
        }
        
    }
    
    @IBAction func botTapped(_ sender: Any) {
        KommunicateManager.shared.openBotChat(vc: self)
    }
    
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var opportunityResultCollectionView: UICollectionView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    var resultsForUsers = [UserProfile]()
    var resultsForPosts = [Post]()
    var resultsForOpportunities = [Opportunity]()
    var hasSearched = false
    
    let userResultCellId = "userResultCell"
    let postResultCellId = "postCell"
    let opportunityResultCellId = "opportunityCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        //register cells
        userResultsTableView.register(UINib(nibName: "userResultsTableViewCell", bundle: nil), forCellReuseIdentifier: userResultCellId)
        
        postTableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: postResultCellId)

        opportunityResultCollectionView.register(UINib(nibName: "OpportunitiesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: opportunityResultCellId)
        
        userResultsTableView.delegate = self
        userResultsTableView.dataSource = self
        userResultsTableView.reloadData()
        
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.reloadData()
        
        opportunityResultCollectionView.dataSource = self
        opportunityResultCollectionView.delegate = self
        opportunityResultCollectionView.reloadData()
        opportunityResultCollectionView.collectionViewLayout = OpportunityViewController.createLayout()
        
        searchBar.delegate = self
    }
    
    func searchThroughOpportunities(searchTerm: String, completion: @escaping (_ searchOpportunityResults: [Opportunity])->()) {
        var opporArray = [Opportunity]()
        
        for x in 0..<opportunities.count {
            let oneInQuestion = opportunities[x]
            
            if oneInQuestion.title.lowercased().contains(searchTerm){
                opporArray.append(oneInQuestion)
            }
            else if oneInQuestion.subtitle.lowercased().contains(searchTerm){
                opporArray.append(oneInQuestion)
            }
            else if oneInQuestion.description.lowercased().contains(searchTerm){
                opporArray.append(oneInQuestion)
            }
        }
        
        return completion(opporArray)
    }
    
    func searchThroughPosts(searchTerm: String, completion: @escaping (_ searchPostResults: [Post])->()) {
        var postArray = [Post]()
        
        for x in 0..<posts.count {
            let oneInQuestion = posts[x]
            
            if oneInQuestion.title.lowercased().contains(searchTerm){
                postArray.append(oneInQuestion)
            }
            else if oneInQuestion.content.lowercased().contains(searchTerm){
                postArray.append(oneInQuestion)
            }
        }
        
        return completion(postArray)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "discoverToUser" {
            let indexPath = userResultsTableView.indexPathForSelectedRow
            let postInDepthVC = segue.destination as! OtherProfileViewController
            postInDepthVC.userProfile = resultsForUsers[indexPath!.row]
        }
        else if segue.identifier == "discoverToPost" {
            let indexPath = postTableView.indexPathForSelectedRow
            let postInDepthVC = segue.destination as! PostDepthViewController
            postInDepthVC.postInQuestion = resultsForPosts[indexPath!.row]
        }
        else if segue.identifier == "discoverToOpportunity" {
            let indexPath = opportunityResultCollectionView.indexPathsForSelectedItems?.first
            let oppInDepthVC = segue.destination as! OpportunityDepthViewController
            let oppAtIndex:Opportunity = resultsForOpportunities[indexPath!.row]
            oppInDepthVC.opportunity = oppAtIndex
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

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == userResultsTableView {
            return resultsForUsers.count
        }
        else {
            return resultsForPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == userResultsTableView {
            return 80
        }
        else {
            return 400
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == userResultsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: userResultCellId, for: indexPath) as! userResultsTableViewCell
            cell.set(userProfile: resultsForUsers[indexPath.row])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: postResultCellId, for: indexPath) as! PostTableViewCell
            cell.set(post: resultsForPosts[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == userResultsTableView {
        performSegue(withIdentifier: "discoverToUser", sender: self)
        }
        else {
            performSegue(withIdentifier: "discoverToPost", sender: self)
        }
    }
}

extension DiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsForOpportunities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = opportunityResultCollectionView.dequeueReusableCell(withReuseIdentifier: opportunityResultCellId, for: indexPath) as! OpportunitiesCollectionViewCell
        
        cell.set(opportunity: resultsForOpportunities[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "discoverToOpportunity", sender: self)
    }
}

extension DiscoverViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("works")
        guard let text = searchBar.text?.lowercased() else {
            return
        }
        print("after guard")
        searchBar.resignFirstResponder()
        
        DatabaseManager.shared.queryUsers(searchTerm: text) { (userResultArray) in
            self.resultsForUsers = userResultArray
            print("searchresults\(self.resultsForUsers)")
            
            if !self.searchLabel.isHidden {
                self.userResultsTableView.isHidden = false
            }
            self.userResultsTableView.reloadData()
        }
        
        searchThroughPosts(searchTerm: text) { (postArray) in
            self.resultsForPosts = postArray
            self.postTableView.reloadData()
        }
        
        searchThroughOpportunities(searchTerm: text) { (opportunityArray) in
            self.resultsForOpportunities = opportunityArray
            self.opportunityResultCollectionView.reloadData()
        }
    }
}


