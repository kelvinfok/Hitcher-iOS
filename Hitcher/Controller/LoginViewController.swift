//
//  LoginViewController.swift
//  Hitcher
//
//  Created by Kelvin Fok on 13/2/18.
//  Copyright © 2018 Kelvin Fok. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: RoundedShadowButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }
    
    func setupViews() {
        view.bindToKeyboard()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let attributes: [AnyHashable : Any] = [NSAttributedStringKey.font : UIFont(name: "AvenirNext-Bold", size: 16.0)!]
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleScreenTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func handleCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func handleLoginButton(_ sender: Any) {
        if let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty {
            loginButton.animate(shouldLoad: true, withMessage: nil)
            self.view.endEditing(true)
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    self.handleFirebaseError(error: error!, shouldCreateUser: { shouldCreateUser in
                        if shouldCreateUser {
                            self.createUser(email: email, password: password)
                        }
                    })
                } else if let user = user {
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        let userData = ["provider" : user.providerID]
                        DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                    } else {
                        let userData: [String : Any] = ["provider" : user.providerID, "userIsDriver" : true, PathManager.Path.isPickUpModeEnabled.rawValue : false, "driverIsOnTrip" : false]
                        DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                    }
                    print("Email user authenticated")
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    func createUser(email: String, password: String) {
        print("Creating user now")
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error!)
            } else if let user = user {
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    let userData = ["provider" : user.providerID]
                    DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                } else {
                    let userData: [String : Any] = ["provider" : user.providerID, "userIsDriver" : true, PathManager.Path.isPickUpModeEnabled.rawValue : false, "driverIsOnTrip" : false]
                    DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                }
                print("Succesfully created a new user")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func handleFirebaseError(error: Error, shouldCreateUser completion: ((Bool) -> Void)? = nil) {
        let codeValue = error._code
        if let errorCode = AuthErrorCode(rawValue: codeValue) {
            switch errorCode {
            case .userNotFound:
                print("User not found")
                completion?(true)
            case .invalidEmail:
                print("Email invalid.")
            case .emailAlreadyInUse:
                print("Email already in use")
            case .wrongPassword:
                print("Password is incorrect")
            default:
                print("Error code \(errorCode). Please try again.")
            }
        }
    }
}
