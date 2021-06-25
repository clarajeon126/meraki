//
//  OpportunityViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 1/27/21.
//

import UIKit

public var opportunities = [Opportunity]()



class OpportunityViewController: UIViewController {
    
    var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var opportunityCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        opportunityCollectionView.register(UINib(nibName: "OpportunitiesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "opportunityCell")
        
        opportunityCollectionView.dataSource = self
        opportunityCollectionView.delegate = self
        opportunityCollectionView.collectionViewLayout = OpportunityViewController.createLayout()
        
        refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            opportunityCollectionView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            opportunityCollectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(reloadCollectionViewData), for: .valueChanged)
        reloadCollectionViewData()
        
    }
    
    @objc func reloadCollectionViewData(){
        DatabaseManager.shared.arrayOfOpportunityByTime { (opportunityArray) in
            opportunities = opportunityArray
            self.opportunityCollectionView.reloadData()
        }
        refreshControl.endRefreshing()
    }
    @IBAction func botTapped(_ sender: Any) {
        KommunicateManager.shared.openBotChat(vc: self)
    }
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
        //items
        let twoByTwo = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
        
        let oneByOne = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalWidth(1/2)))
        
        let twoByOne = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalWidth(1)))
        
        let oneByTwo = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2)))
        
        let insets:CGFloat = 6
        
        //padding for the cells
        twoByTwo.contentInsets = NSDirectionalEdgeInsets(top: insets, leading: insets, bottom: insets, trailing: insets)
        oneByOne.contentInsets = NSDirectionalEdgeInsets(top: insets, leading: insets, bottom: insets, trailing: insets)
        twoByOne.contentInsets = NSDirectionalEdgeInsets(top: insets, leading: insets, bottom: insets, trailing: insets)
        oneByTwo.contentInsets = NSDirectionalEdgeInsets(top: insets, leading: insets, bottom: insets, trailing: insets)

        
        //groups
        /*let oneByOne = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1/2),
                                                            heightDimension: .fractionalWidth(1/2)),
                                                        subitem: twoByTwo, count: 1)*/
        
        /*let oneByTwo = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1/2),
                                                            heightDimension: .fractionalWidth(1)),
                                                        subitem: twoByTwo, count: 1)*/
        
        let group2 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalWidth(1/2)),
                                                        subitem: oneByTwo, count: 2)
        
        let group3 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1/2),
                                                            heightDimension: .fractionalWidth(1)),
                                                        subitem: twoByTwo, count: 2)
        
        let group5 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalWidth(1)),
                                                        subitems: [twoByOne, group3])
        
        let group6 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalWidth(1)),
                                                        subitems: [group3, twoByOne])
        let group7 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalWidth(1)),
                                                        subitems: [twoByOne, twoByOne])
        let group8 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalWidth(1)),
                                                        subitems: [group3, group3])
        let group9 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                                                        widthDimension: .fractionalWidth(1),
                                                        heightDimension: .fractionalWidth(1)),
                                                    subitems: [oneByTwo, oneByTwo])
        let group10 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                                                        widthDimension: .fractionalWidth(1),
                                                        heightDimension: .fractionalWidth(1)),
                                                    subitems: [group2, oneByTwo])
        let group11 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                                                        widthDimension: .fractionalWidth(1),
                                                        heightDimension: .fractionalWidth(1)),
                                                    subitems: [oneByTwo, group2])
        
        let finalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalWidth(11)),
                                                        subitems: [oneByTwo, twoByTwo, group5, group9, group11, twoByTwo, group8, group7, group10, twoByTwo, group6, oneByTwo])

        
        
        let section = NSCollectionLayoutSection(group: finalGroup)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "opportunityInDepthSegue" {
            let indexPath = opportunityCollectionView.indexPathsForSelectedItems?.first
            let oppInDepthVC = segue.destination as! OpportunityDepthViewController
            let oppAtIndex:Opportunity = opportunities[indexPath!.row]
            oppInDepthVC.opportunity = oppAtIndex
        }
    }

}

extension OpportunityViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return opportunities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = opportunityCollectionView.dequeueReusableCell(withReuseIdentifier: "opportunityCell", for: indexPath) as! OpportunitiesCollectionViewCell
        
        cell.set(opportunity: opportunities[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "opportunityInDepthSegue", sender: self)
    }
}
