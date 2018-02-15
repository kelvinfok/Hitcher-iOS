//
//  LeftSidePanelViewController.swift
//  Hitcher
//
//  Created by Kelvin Fok on 11/2/18.
//  Copyright © 2018 Kelvin Fok. All rights reserved.
//

import UIKit
import Firebase

class PanelViewController: UIViewController {
    
    var currentUser: User?
    let appDelegate = AppDelegate.getAppDelegate()
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var profileImageView: RoundImageView!
    @IBOutlet weak var pickUpModeLabel: UILabel!
    @IBOutlet weak var pickUpModeSwitch: UISwitch!
    @IBOutlet weak var signUpLoginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViews()
        observerPassengersAndDrivers()
    }
    
    func setupInitialViews() {
        pickUpModeSwitch.isOn = false
        pickUpModeSwitch.isHidden = true
        pickUpModeLabel.isHidden = true
        
        if let currentUser = Auth.auth().currentUser {
            self.currentUser = currentUser
            displayUserIsLoginViews()
        } else {
            displayUserIsLogoutViews()
        }
    }
    
    func displayUserIsLogoutViews() {
        emailLabel.text = ""
        accountTypeLabel.text = ""
        profileImageView.isHidden = true
        signUpLoginButton.setTitle("Sign Up / Login", for: .normal)
    }
    
    func displayUserIsLoginViews() {
        emailLabel.text = Auth.auth().currentUser?.email
        accountTypeLabel.text = ""
        profileImageView.isHidden = false
        signUpLoginButton.setTitle("Logout", for: .normal)
    }
    
    func observerPassengersAndDrivers() {
        
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snapshot in snapshots {
                    if snapshot.key == Auth.auth().currentUser?.uid {
                        Session.instance.userType = .PASSENGER
                        print("is passenger")
                        self.accountTypeLabel.text = "Passenger"
                    }
                }
            }
        }
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snapshot in snapshots {
                    if snapshot.key == Auth.auth().currentUser?.uid {
                        print("is driver")
                        Session.instance.userType = .DRIVER
                        self.accountTypeLabel.text = "Driver"
                        self.pickUpModeSwitch.isHidden = false
                        let switchStatus = snapshot.childSnapshot(forPath: "isPickupModeEnabled").value as! Bool
                        self.pickUpModeSwitch.isOn = switchStatus
                        self.pickUpModeLabel.isHidden = false
                    }
                }
            }
        }
    }

    @IBAction func handleSignUpLoginButton(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let loginViewController = UIStoryboard.getMainStoryboard().instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(loginViewController, animated: true, completion: nil)
        } else {
            do {
                try Auth.auth().signOut()
                displayUserIsLogoutViews()
            } catch (let error ) {
                print("Sign out error: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func handlePickUpModeSwitch(_ sender: Any) {
        if pickUpModeSwitch.isOn {
            pickUpModeLabel.text = "Pickup Mode Enabled"
            appDelegate.containerViewController.toggleLeftPanel()
            let dictionary = ["isPickupModeEnabled" : true]
            DataService.instance.REF_DRIVERS.child(self.currentUser!.uid).updateChildValues(dictionary)
        } else {
            pickUpModeLabel.text = "Pickup Mode Disabled"
            appDelegate.containerViewController.toggleLeftPanel()
            let dictionary = ["isPickupModeEnabled" : false]
            DataService.instance.REF_DRIVERS.child(self.currentUser!.uid).updateChildValues(dictionary)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}
