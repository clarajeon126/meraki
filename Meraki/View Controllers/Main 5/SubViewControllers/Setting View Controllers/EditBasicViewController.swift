//
//  EditBasicViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 2/12/21.
//

import UIKit

class EditBasicViewController: UIViewController {
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var headlineTextField: UITextField!
    @IBAction func changeImageButtonTapped(_ sender: Any) {
        //image picker for changing profile image
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    @IBAction func changeFirstLastButtonTapped(_ sender: Any) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        if let changedFirstName = firstNameTextField.text, !changedFirstName.isEmpty,
           let changedLastName = lastNameTextField.text, !changedLastName.isEmpty {
            DatabaseManager.shared.changeFirstLastNameUser(newFirst: changedFirstName, newLast: changedLastName)
            UserProfile.currentUserProfile?.firstName = changedFirstName
            UserProfile.currentUserProfile?.lastName = changedLastName
            firstNameTextField.text = ""
            lastNameTextField.text = ""
        }
    }
    @IBAction func changeHeadlineButtonTapped(_ sender: Any) {
        headlineTextField.resignFirstResponder()
        
        if let changedHeadline = headlineTextField.text, !changedHeadline.isEmpty {
            DatabaseManager.shared.changeHeadlineUser(newHeadline: changedHeadline)
            UserProfile.currentUserProfile?.headline = changedHeadline
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        let currentUser = UserProfile.currentUserProfile!
        // Do any additional setup after loading the view.
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.width / 2
        
        profilePhotoImageView.image = nil
        ImageService.getImage(withURL: currentUser.profilePhotoURL) { (image, url) in
            self.profilePhotoImageView.image = image
        }
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        headlineTextField.delegate = self
        
        firstNameTextField.text = currentUser.firstName
        lastNameTextField.text = currentUser.lastName
        headlineTextField.text = currentUser.headline
        
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
extension EditBasicViewController: UITextFieldDelegate {
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        }
        else if textField == lastNameTextField {
            changeFirstLastButtonTapped(self)
        }
        else if textField == headlineTextField {
            changeHeadlineButtonTapped(self)
        }
        return true
    }*/
}

extension EditBasicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage
        ] as? UIImage {
            self.profilePhotoImageView.image = pickedImage
            StorageManager.shared.changeProfilePhoto(image: pickedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
