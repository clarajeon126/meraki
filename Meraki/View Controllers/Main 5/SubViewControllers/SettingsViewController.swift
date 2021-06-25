//
//  SettingsViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 2/1/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingTableView: UITableView!
    
    @IBAction func signOutTapped(_ sender: Any) {
        AuthManager.shared.logOut(completion: {success in
            DispatchQueue.main.async {
                if success {
                    UserProfile.currentUserProfile = nil
                    
                    let startingStoryBoard = UIStoryboard(name: "Starting", bundle: nil)
                    let loginVC = startingStoryBoard.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true) {
                        self.navigationController?.popToRootViewController(animated: false)
                        self.tabBarController?.selectedIndex = 2
                    }
                }
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.dataSource = self
        settingTableView.delegate = self
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

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = settingTableView.dequeueReusableCell(withIdentifier: "editBasicProfileCell", for: indexPath)
            return cell
        }
        else if indexPath.row == 1 {
            let cell = settingTableView.dequeueReusableCell(withIdentifier: "editAboutYouCell", for: indexPath)
            return cell
        }
        else if indexPath.row == 2 {
            let cell = settingTableView.dequeueReusableCell(withIdentifier: "signOutCell", for: indexPath)
            return cell
        }
        else if indexPath.row == 3{
            let cell = settingTableView.dequeueReusableCell(withIdentifier: "copyrightsCell", for: indexPath)
            return cell
        }
        else {
            let cell = settingTableView.dequeueReusableCell(withIdentifier: "bugCell", for: indexPath)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "toEditBasicProfile", sender: self)
        }
        else if indexPath.row == 1 {
            performSegue(withIdentifier: "toEditAbout", sender: self)
        }
        else if indexPath.row == 2 {
            let alert = UIAlertController(title: "Sign out?", message: "Are you sure you want to sign out?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { (AlertAction) in
                self.signOutTapped(self)
            }))
            alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        else if indexPath.row == 3 {
            performSegue(withIdentifier: "toCredits", sender: self)
        }
        else if indexPath.row == 4 {
            performSegue(withIdentifier: "toBugReport", sender: self)
        }
    }
}
