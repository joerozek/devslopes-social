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
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("going to next view")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
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
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user:User?, error) in
                if error == nil {
                    print("JOE: User authenticated with email")
                    self.completeSignIn(user: user)
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user:User?, error) in
                        if error != nil {
                            print("JOE: unable to authenticate user with firebase \(String(describing: error))")
                        } else {
                            self.completeSignIn(user: user)
                            print("JOE: Successfully authenicated the user with firebase")
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(user: User?) {
        print("complete sign in")
        if let user = user {
            print("adding to keychain")
            KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    func firebaseAuthentication(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user:User?, error) in
            if error != nil {
                print ("JOE: unable to authenicate with firebase ")
            } else {
                print("JOE: signed in with firebase")
                self.completeSignIn(user: user)
            }
        })
    }
}

