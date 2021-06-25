//
//  KommunicateManager.swift
//  Meraki
//
//  Created by Clara Jeon on 6/25/21.
//

import Foundation
import Kommunicate

public class KommunicateManager {
    static let shared = KommunicateManager()
    
    public func openBotChat(vc: UIViewController) {
        Kommunicate.createAndShowConversation(from: vc) { error in
            guard error == nil else {
                print("Conversation error: \(error.debugDescription)")
                return
            }
            // Success
        }
    }
    
    public func registerUser() {
        let userId = Kommunicate.randomId()
        print(userId)
        let kmUser = KMUser()
        kmUser.userId = userId
        kmUser.displayName = UserProfile.currentUserProfile?.firstName
        kmUser.applicationId = "168b157c6261ba66ce468994213834b28"

        // Use this same API for login
        Kommunicate.registerUser(kmUser, completion: {
            response, error in
            guard error == nil else {return}
            print("Success")
        })
    }
}
