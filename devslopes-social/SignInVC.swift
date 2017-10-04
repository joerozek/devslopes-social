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
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    if let user = user {
                        print("JOE: User authenticated with email")
                        let userData = ["provider" : user.providerID]
                        self.completeSignIn(uid: user.uid, userData: userData)
                    }
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user:User?, error) in
                        if error != nil {
                            print("JOE: unable to authenticate user with firebase \(String(describing: error))")
                        } else {
                            if let user = user {
                                let userData = ["provider" : user.providerID]
                                self.completeSignIn(uid: user.uid, userData: userData)
                                print("JOE: Successfully authenicated the user with firebase")
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(uid: String, userData:Dictionary<String, String>) {
        DataService.ds.createFireBaseDBUser(uid:uid, userData: userData)
        let _ = KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        print("adding to keychain")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    func firebaseAuthentication(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user:User?, error) in
            if error != nil {
                print ("JOE: unable to authenicate with firebase ")
            } else {
                if let user = user {
                    print("JOE: signed in with firebase \(credential.provider)")
                    let userData = ["provider" : credential.provider]

                    self.completeSignIn(uid: user.uid, userData: userData)
                }
            }
        })
    }
}

