//
//  bugViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 6/15/21.
//

import UIKit

class bugViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBAction func submitButtonTapped(_ sender: Any) {
        if !textView.text.isEmpty {
            DatabaseManager.shared.addFeedback(feedbackMessage: textView.text)
            let alert = UIAlertController(title: "Success!", message: "You report was sent to the developers. Thank you!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = mainColor.cgColor
        submitButton.layer.cornerRadius = 15
        textView.layer.cornerRadius = 15
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
