//
//  ViewController.swift
//  devslopes-social
//
//  Created by Joe Rozek on 9/11/17.
//  Copyright © 2017 Joe Rozek. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("JOE: unable to auth with facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("JOE: user cancelled")
            } else {
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuthentication(credential)
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("JOE: User authenticated with email")
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("JOE: unable to authenticate user with firebase \(String(describing: error))")
                        } else {
                            if let user = user {
                                KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
                            }
                            print("JOE: Successfully authenicated the user with firebase")
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(user: AnyObject) {
        
    }
    
    func firebaseAuthentication(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print ("JOE: unable to authenicate with firebase ")
            } else {
                print("JOE: signed in with firebase")
            }
        })
    }
}

