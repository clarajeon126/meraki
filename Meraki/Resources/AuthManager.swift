//
//  AuthManager.swift
//  Meraki
//
//  Created by Clara Jeon on 1/28/21.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

public class AuthManager {
    
    static let shared = AuthManager()
    
    //get user id (mostly for google sign in and stuff)
    public func getUserId() -> String?{
        guard let uid = Auth.auth().currentUser?.uid else {
            return "not signed in"
        }
        return uid
    }
    
    //to register new user
    public func registerNewUser(username: String, email: String, password: String, firstName: String, lastName: String, completion: @escaping (Bool) -> Void){
        
        //check if there are no duplicates
        DatabaseManager.shared.canCreateNewUser(with: email, username: username){ canCreate in
            if canCreate {
                
                //create user
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    guard error == nil, result != nil else{
                        completion(false)
                        return
                }
                    
                let defaultProfilePhoto = #imageLiteral(resourceName: "blankprofilepic")
                    
                    StorageManager.shared.uploadGeneralProfilePhoto(defaultProfilePhoto) { (url) in
                        if url != nil {
                            DatabaseManager.shared.insertNewUser(with: email, username: username, firstName: firstName, lastName: lastName, uid: self.getUserId() ?? "no user id", userProfilePhotoUrl: url!) { (inserted) in
                                if inserted {
                                    //creating user profile
                                    UserProfile.currentUserProfile = UserProfile(uid: self.getUserId() ?? "no user id", username: username, firstName: firstName, lastName: lastName, headline: " ", profilePhotoURL: url!)
                                    completion(true)
                                    return
                                }
                                else {
                                    completion(false)
                                    return
                                }
                            }
                        }
                    }
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    //to log in user
    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void){
        if let email = email {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
        else if let username = username {
            print(username)
            
        }
    }
    
    //to log out a user
    public func logOut(completion: (Bool) -> Void){
        do {
            try Auth.auth().signOut()
            UserProfile.currentUserProfile = nil
            completion(true)
            return
        }
        catch {
            print(error)
            completion(false)
            return
        }
    }
}
