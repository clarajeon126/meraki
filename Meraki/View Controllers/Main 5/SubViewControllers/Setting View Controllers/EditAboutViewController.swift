//
//  EditAboutViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 2/12/21.
//

import UIKit

let mainColor = UIColor(red: 230/255, green: 57/255, blue: 70/255, alpha: 1)
class EditAboutViewController: UIViewController {

    @IBOutlet var answerTextView: [UITextView]!
    @IBOutlet weak var whoAreYouAnswer: UITextView!
    @IBOutlet weak var merakiProjectAnswer: UITextView!
    @IBOutlet weak var skillsAnswer: UITextView!
    @IBOutlet weak var accomplishmentsAnswer: UITextView!
    @IBOutlet weak var passionAnswer: UITextView!
    
    @IBOutlet weak var doneLabel: UILabel!
    @IBAction func changeButtonTapped(_ sender: Any) {
        if let whoAreYouAns = whoAreYouAnswer.text, !whoAreYouAns.isEmpty,
           let merakiProjectAns = merakiProjectAnswer.text, !merakiProjectAns.isEmpty,
           let skillsAns = skillsAnswer.text, !skillsAns.isEmpty,
           let accomplishmentsAns = accomplishmentsAnswer.text, !accomplishmentsAns.isEmpty,
           let passionAns = passionAnswer.text, !passionAns.isEmpty {
            let aboutUser = AboutUser(whoAreYou: whoAreYouAns, merakiProject: merakiProjectAns, skills: skillsAns, accomplishments: accomplishmentsAns, passion: passionAns)
            DatabaseManager.shared.addAboutUser(aboutUser: aboutUser)
            
            //doneLabel animation
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                self.doneLabel.alpha = 1.0
                }, completion: {
                (finished: Bool) -> Void in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn,
                animations: { self.doneLabel.alpha = 0.0
                }, completion: nil)
            })
        }
           
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        guard let currentUserUid = UserProfile.currentUserProfile?.uid else {
            return
        }
        DatabaseManager.shared.getAboutUser(uid: currentUserUid) { (aboutUser) in
            self.whoAreYouAnswer.text = aboutUser.whoAreYou
            self.merakiProjectAnswer.text = aboutUser.merakiProject
            self.skillsAnswer.text = aboutUser.skills
            self.accomplishmentsAnswer.text = aboutUser.accomplishments
            self.passionAnswer.text = aboutUser.passion
        }
        
        for x in 0..<answerTextView.count {
            let textField = answerTextView[x]
            textField.delegate = self
            textField.layer.cornerRadius = 15
            textField.layer.borderWidth = 1
            textField.layer.borderColor = mainColor.cgColor
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

extension EditAboutViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == whoAreYouAnswer {
            merakiProjectAnswer.becomeFirstResponder()
        }
        else if textView == merakiProjectAnswer {
            skillsAnswer.becomeFirstResponder()
        }
        else if textView == skillsAnswer {
            accomplishmentsAnswer.becomeFirstResponder()
        }
        else if textView == accomplishmentsAnswer {
            passionAnswer.becomeFirstResponder()
        }
        else if textView == passionAnswer {
            changeButtonTapped(self)
        }
        
    }
    
}

/*extension EditAboutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = aboutYouTableView.dequeueReusableCell(withIdentifier: aboutQuestionCellId, for: indexPath) as! aboutQuestionsTableViewCell
        
        if indexPath.row == 0 {
            cell.set(questionForCell: "Who are you?")
            return cell
        }
        else if indexPath.row == 1 {
            cell.set(questionForCell: "What is your Meraki Project?")
            return cell
            
        }
        else if indexPath.row == 2 {
            cell.set(questionForCell: "Skills, talents: What are you good at?")
            return cell
        }
        else if indexPath.row == 3 {
            cell.set(questionForCell: "Accomplishments: What are you proud of?")
            return cell
        }
        else {
            cell.set(questionForCell: "What is your passion, your SPARK?")
            return cell
        }
    }
    
    
}*/

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
