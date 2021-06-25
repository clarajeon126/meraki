//
//  StorageManager.swift
//  Meraki
//
//  Created by Clara Jeon on 1/28/21.
//

import Foundation
import UIKit
import FirebaseStorage

public class StorageManager {
    
    static let shared = StorageManager()

    let storage = Storage.storage().reference()
    
    let profilePhotoRef = Storage.storage().reference().child("Profile Photos")
    
    public func uploadGoogleUrlProfilePhoto(_ googleUrl: String, completion: @escaping ((_ url: URL?) -> ())){
        
        //setting the google url string to data to store to firebase storage
        let url  = NSURL(string: googleUrl)! as URL
        let data = NSData(contentsOf: url)
        
        uploadProfilePhoto(data! as Data) { (imageUrl) in
            if imageUrl != nil {
                completion(imageUrl)
            }
            else {
                completion(nil)
            }
        }
    }
    
    //upload the profile photo using its data
    private func uploadProfilePhoto(_ imageData: Data, completion: @escaping((_ url: URL?) -> ())){
        
        //setting uid variable
        guard let uid = AuthManager.shared.getUserId() else {
            return
        }
        
        //meta data stuff for putting things in storage
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        let userProfilePhotoRef = profilePhotoRef.child(uid)
        
        userProfilePhotoRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                userProfilePhotoRef.downloadURL { (url, error) in
                    completion(url)
                }
            }
            else {
                completion(nil)
            }
        }
    }
    
    //uploading user profile with UIImage used for default and making changes to profile pic
    public func uploadGeneralProfilePhoto(_ image:UIImage, completion: @escaping((_ url: URL?) -> ())){
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            return
        }
        
        uploadProfilePhoto(imageData) { (imageUrl) in
            if imageUrl != nil {
                completion(imageUrl)
            }
            else {
                completion(nil)
            }
        }
    }
    func uploadPostImage(image:UIImage, withAutoId: String,  completion: @escaping ((_ url:URL?)->())) {
        let storageRef = Storage.storage().reference().child("PostPhotos")
        let postPhotoRef = storageRef.child(withAutoId)
            
            guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            postPhotoRef.putData(imageData, metadata: metaData) { metaData, error in
                if error == nil, metaData != nil {
                    
                    postPhotoRef.downloadURL { url, error in
                        completion(url)
                    }
                } else {
                    // failed
                    completion(nil)
                }
            }
        }
    public func changeProfilePhoto(image:UIImage){
        guard let userProfileUid = UserProfile.currentUserProfile?.uid else {
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            return
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        profilePhotoRef.child(userProfileUid).putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                self.profilePhotoRef.child(userProfileUid).downloadURL { url, error in
                    DatabaseManager.shared.changeProfilePhotoUser(newProfilePhotoUrl: url!.absoluteString)
                }
            }
        }
    }
    
    public func uploadOpportunityPhoto(image: UIImage, withAutoId: String, completion: @escaping ((_ url: URL?)->())){
        let storageRef = Storage.storage().reference().child("OpportunityPhotos")
        let postPhotoRef = storageRef.child(withAutoId)
            
            guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            postPhotoRef.putData(imageData, metadata: metaData) { metaData, error in
                if error == nil, metaData != nil {
                    
                    postPhotoRef.downloadURL { url, error in
                        completion(url)
                    }
                } else {
                    // failed
                    completion(nil)
                }
            }
    }
}
