//
//  CreateOpportunityViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 2/1/21.
//

import UIKit

class CreateOpportunityViewController: UIViewController {

    var imagePicker: UIImagePickerController!
    
    var category = "not chosen"
    //categorty of STEAM buttons
    @IBOutlet weak var scienceButton: UIButton!
    @IBOutlet weak var technologyButton: UIButton!
    @IBOutlet weak var engineeringButton: UIButton!
    @IBOutlet weak var artButton: UIButton!
    @IBOutlet weak var mathButton: UIButton!
    
    
    
    func checkingForOtherCategoryTapped(){
        if category == "science"{
            scienceButton.borderWidth = 0
        }
        else if category == "technology"{
            technologyButton.borderWidth = 0
        }
        else if category == "engineering"{
            engineeringButton.borderWidth = 0
        }
        else if category == "arts"{
            artButton.borderWidth = 0
        }
        else if category == "math"{
            mathButton.borderWidth = 0
        }
    }
    @IBAction func scienceTapped(_ sender: Any) {

        if category != "science" {
            if category != "not chosen" {
                checkingForOtherCategoryTapped()
            }
            
            category = "science"
            scienceButton.borderWidth = 3
        }
        else {
            category = "not chosen"
            scienceButton.borderWidth = 0
        }
    }
    @IBAction func technologyTapped(_ sender: Any) {
        if category != "technology" {
            if category != "not chosen" {
                checkingForOtherCategoryTapped()
            }
            category = "technology"
            technologyButton.borderWidth = 3
        }
        else {
            category = "not chosen"
            technologyButton.borderWidth = 0
        }
    }
    @IBAction func engineeringTapped(_ sender: Any) {
        if category != "engineering" {
            if category != "not chosen" {
                checkingForOtherCategoryTapped()
            }
            category = "engineering"
            engineeringButton.borderWidth = 3
        }
        else {
            category = "not chosen"
            engineeringButton.borderWidth = 0
        }
    }
    @IBAction func artsTapped(_ sender: Any) {
        if category != "arts" {
            if category != "not chosen" {
                checkingForOtherCategoryTapped()
            }
            category = "arts"
            artButton.borderWidth = 3
        }
        else {
            category = "not chosen"
            artButton.borderWidth = 0
        }
    }
    @IBAction func mathTapped(_ sender: Any) {
        if category != "math" {
            if category != "not chosen" {
                checkingForOtherCategoryTapped()
            }
            category = "math"
            mathButton.borderWidth = 3
        }
        else {
            category = "not chosen"
            mathButton.borderWidth = 0
        }
    }
    
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addAnImage: UIButton!
    @IBAction func addImageButtonTapped(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        if let title = titleTextField.text, !title.isEmpty,
           let subtitle = subtitleTextView.text, !subtitle.isEmpty,
           let description = descriptionTextView.text, !description.isEmpty,
           let image = imageView.image, !(category == "not chosen") {
            
            let startDate = startDatePicker.date.timeIntervalSince1970
            let endDate = endDatePicker.date.timeIntervalSince1970 as Double
            
            DatabaseManager.shared.addOpportunity(title: title, subtitle: subtitle, description: description, dateStart: startDate, dateEnd: endDate, image: image, category: category)
            performSegue(withIdentifier: "createOpportunityToMain", sender: self)
            
        }
        else {
            let alert = UIAlertController(title: "Unable to post your opportunity", message: "Please double-check if you have filled out all fields including the selction of the category and image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        titleTextField.delegate = self
        subtitleTextView.delegate = self
        descriptionTextView.delegate = self
        
        subtitleTextView.layer.cornerRadius = 15
        subtitleTextView.layer.borderWidth = 1
        subtitleTextView.layer.borderColor = mainColor.cgColor
        
        
        descriptionTextView.layer.cornerRadius = 15
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = mainColor.cgColor
        
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
extension CreateOpportunityViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == subtitleTextView {
            subtitleTextView.resignFirstResponder()
        }
        else if textView == descriptionTextView {
            descriptionTextView.resignFirstResponder()
        }
    }
}

extension CreateOpportunityViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage {
            self.imageView.image = pickedImage
            self.addAnImage.isHidden = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
