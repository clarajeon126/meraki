//
//  CreatePostViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 2/1/21.
//

import UIKit
import FirebaseDatabase

protocol NewPostVCDelegate {
    func didUploadPost(withID id:String)
}
class CreatePostViewController: UIViewController {
    
    var delegate:NewPostVCDelegate?
    var typeOfPost = "not chosen yet"
    var selectedTypeButton: UIButton? = nil
    
    var imagePicker:UIImagePickerController!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextField!
    
    
    @IBOutlet weak var addAnImage: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func addAnImageTapped(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var discussionButton: UIButton!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var funButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    @IBAction func discussionButtonTapped(_ sender: Any) {
        if typeOfPost == "not chosen yet" {
            typeOfPost = "Discussion"
            selectedTypeButton = discussionButton
            discussionButton.borderWidth = 3
        }
        else if typeOfPost != "Discussion" {
            selectedTypeButton?.borderWidth = 0
            discussionButton.borderWidth = 3
            typeOfPost = "Discussion"
            selectedTypeButton = discussionButton
        }
    }
    @IBAction func questionsButtonTapped(_ sender: Any) {
        if typeOfPost == "not chosen yet" {
            typeOfPost = "Questions"
            selectedTypeButton = questionButton
            questionButton.borderWidth = 3
        }
        else if typeOfPost != "Questions" {
            selectedTypeButton?.borderWidth = 0
            questionButton.borderWidth = 3
            typeOfPost = "Questions"
            selectedTypeButton = questionButton
        }
    }
    @IBAction func funButtonTapped(_ sender: Any) {
        if typeOfPost == "not chosen yet" {
            typeOfPost = "Fun"
            selectedTypeButton = funButton
            funButton.borderWidth = 3
        }
        else if typeOfPost != "Fun" {
            selectedTypeButton?.borderWidth = 0
            funButton.borderWidth = 3
            typeOfPost = "Fun"
            selectedTypeButton = funButton
        }
    }
    @IBAction func otherButtonTapped(_ sender: Any) {
        if typeOfPost == "not chosen yet" {
            typeOfPost = "Other"
            selectedTypeButton = otherButton
            otherButton.borderWidth = 3
        }
        else if typeOfPost != "Other" {
            selectedTypeButton?.borderWidth = 0
            otherButton.borderWidth = 3
            typeOfPost = "Other"
            selectedTypeButton = otherButton
        }
    }
    
    //action when upload button is tapped
    @IBAction func uploadPostButtonTapped(_ sender: Any) {
        titleTextField.resignFirstResponder()
        contentTextField.resignFirstResponder()
        
        guard let titleText = titleTextField.text, !titleText.isEmpty,
              let contentText = contentTextField.text, !contentText.isEmpty,
              let imageForPost = imageView.image, !(typeOfPost == "not chosen yet") else {
            return
        }
        let newPost = PostWithUIImage(typeOfPost: typeOfPost, titleOfPost: titleText, isAnonymous: false, imageUI: imageForPost, contentOfPost: contentText, author: UserProfile.currentUserProfile!)
        
            addAPost(newPost: newPost) { (success) in
                if success {
                }
                else {
                    /*let alert = UIAlertController(title: "Error when creating your post", message: "There was an error in creating and uploading your post. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true)*/
                }
            }
        
        self.performSegue(withIdentifier: "doneWithUploadingPost", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        titleTextField.returnKeyType = .next
        titleTextField.autocorrectionType = .yes
        titleTextField.autocapitalizationType = .allCharacters
        titleTextField.delegate = self
        
        contentTextField.returnKeyType = .next
        contentTextField.autocorrectionType = .yes
        contentTextField.autocapitalizationType = .allCharacters
        contentTextField.delegate = self
        
    }
    

    public func addAPost(newPost: PostWithUIImage, completion: @escaping (Bool) -> Void){
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        
        StorageManager.shared.uploadPostImage(image: newPost.image, withAutoId: postRef.key!) { (url) in
            if url != nil {
                let imageURL = url!
                let postObject = ["uid": newPost.author.uid,
                                  "mainTitle": newPost.title,
                                  "content": newPost.content,
                                  "type": newPost.type,
                                  "imageurl": imageURL.absoluteString,
                                  "isAnonymous": false,
                                  "timestamp": [".sv":"timestamp"]
                ] as [String:Any]

                postRef.setValue(postObject) { (error, ref) in
                    if error == nil {
                        self.delegate?.didUploadPost(withID: ref.key!)
                    } else {
                        // Handle the error
                    }
                }
            }
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

extension CreatePostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            contentTextField.becomeFirstResponder()
        }
        else {
            uploadPostButtonTapped(self)
        }
        return true
    }
}

extension CreatePostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage
        ] as? UIImage {
            self.imageView.image = pickedImage
            self.addAnImage.isHidden = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
