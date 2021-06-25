//
//  LoginViewController.swift
//  Meraki
//
//  Created by Clara Jeon on 1/27/21.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameOrEmail: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func signInButton(_ sender: Any) {
        passwordField.resignFirstResponder()
        usernameOrEmail.resignFirstResponder()
        
        guard let usernameEmail = usernameOrEmail.text, !usernameEmail.isEmpty, let password = passwordField.text, !password.isEmpty else {
            return
        }
        
        var username: String?
        var email: String?
        
        if usernameEmail.contains("@"), usernameEmail.contains("."){
            email = usernameEmail
        }
        else {
            username = usernameEmail
        }
        //login function
        AuthManager.shared.loginUser(username: username, email: email, password: password){ success in
            DispatchQueue.main.async {
                if success {
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Log In Error", message: "Unable to log in to Meraki. Please check your account information or create an account.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
            
        usernameOrEmail.returnKeyType = .next
        passwordField.returnKeyType = .continue
        
        usernameOrEmail.autocorrectionType = .no
        passwordField.autocorrectionType = .no
        
        usernameOrEmail.autocapitalizationType = .none
        passwordField.autocapitalizationType = .none
        
        usernameOrEmail.delegate = self
        passwordField.delegate = self
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //GIDSignIn.sharedInstance().signIn()
        
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(userDidSignInGoogle(_:)),
                                                   name: .signInGoogleCompleted,
                                                   object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func userDidSignInGoogle(_ notification: Notification) {
        // Update screen after user successfully signed in
        print(Auth.auth().currentUser!.uid)
        DatabaseManager.shared.changeUid()
        updateScreen()
    }
    
    private func updateScreen() {
            performSegue(withIdentifier: "loginToMain", sender: self)
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameOrEmail {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            signInButton(self)
        }
        return true
    }
}
