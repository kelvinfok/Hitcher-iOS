//
//  UpdateService.swift
//  Hitcher
//
//  Created by Kelvin Fok on 15/2/18.
//  Copyright © 2018 Kelvin Fok. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class UpdateService {
    
    static var instance = UpdateService()
    
    func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            
            if let userSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for userSnapshot in userSnapshots {
                    if userSnapshot.key == Auth.auth().currentUser?.uid {
                        let dictionary = ["coordinate" : [coordinate.longitude, coordinate.latitude]]
                        DataService.instance.REF_USERS.child(userSnapshot.key).updateChildValues(dictionary)
                        break
                    }
                }
            }
        }
    }

    func updateDriverLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
            if let driverSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for driverSnapshot in driverSnapshots {
                    if driverSnapshot.key == Auth.auth().currentUser?.uid {
                        if driverSnapshot.childSnapshot(forPath: PathManager.Path.isPickUpModeEnabled.rawValue).value as? Bool == true {
                            let dictionary = ["coordinate" : [coordinate.longitude, coordinate.latitude]]
                            DataService.instance.REF_DRIVERS.child(driverSnapshot.key).updateChildValues(dictionary)
                        }
                    }
                }
            }
        }
    }
}
