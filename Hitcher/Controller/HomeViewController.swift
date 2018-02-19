//
//  ViewController.swift
//  Hitcher
//
//  Created by Kelvin Fok on 10/2/18.
//  Copyright © 2018 Kelvin Fok. All rights reserved.
//

import UIKit
import MapKit
import RevealingSplashView
import CoreLocation
import Firebase

class HomeViewController: UIViewController {
        
    @IBOutlet weak var requestRideButton: RoundedShadowButton!
    @IBOutlet weak var mapView: MKMapView!

    var delegate: CenterViewControllerDelegate?
    var regionRadius: CLLocationDistance = 1000
    var locationManager: CLLocationManager?
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashView()
        setupMapView()
        setupLocationManager()
        checkLocationAuthStatus()
        centerMapOnUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeDrivers()
    }
    
    func observeDrivers() {
        DataService.instance.REF_DRIVERS.observe(.value) { (snapshot) in
            self.loadDriverAnnotationFromFireBase()
        }
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.delegate = self
    }
    
    func setupSplashView() {
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = .heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
    }
    
    func setupMapView() {
        mapView.delegate = self
    }
    
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        } else {
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    func loadDriverAnnotationFromFireBase() {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
            if let driversSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for driverSnapshot in driversSnapshot {
                    if driverSnapshot.hasChild("userIsDriver") {
                        if driverSnapshot.hasChild(PathManager.Path.coordinate.rawValue) {
                            if driverSnapshot.childSnapshot(forPath: PathManager.Path.isPickUpModeEnabled.rawValue).value as? Bool == true {
                                if let driverDictionary = driverSnapshot.value as? [String : Any] {
                                    if let coordinateArray = driverDictionary[PathManager.Path.coordinate.rawValue] as? NSArray {
                                        let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[1] as! CLLocationDegrees, longitude: coordinateArray[0] as! CLLocationDegrees)
                                        let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driverSnapshot.key)
                                        var driverIsVisible: Bool {
                                            return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                                if let driverAnnotation = annotation as? DriverAnnotation {
                                                    if driverAnnotation.key == driverSnapshot.key {
                                                        driverAnnotation.update(annotationPosition: driverAnnotation, withCoordinate: driverCoordinate)
                                                        return true
                                                    }
                                                }
                                                return false
                                            })
                                        }
                                        if !driverIsVisible {
                                            self.mapView.addAnnotation(annotation)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func centerMapOnUserLocation() {
        let centerCoordinate = mapView.userLocation.coordinate
        let latitudalMeters = regionRadius * 2
        let longitutinalMeters = regionRadius * 2
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, latitudalMeters, longitutinalMeters)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func handleRequestRideButton(_ sender: Any) {
        requestRideButton.animate(shouldLoad: true, withMessage: nil)
    }
    
    @IBAction func handleMenuBarButton(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    
    @IBAction func handleCenterMapButton(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthStatus()
        if status == .authorizedAlways {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
}

extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let userType = Session.instance.userType {
            switch userType {
            case .DRIVER:
                UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
            case .PASSENGER:
                UpdateService.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "driverAnnotation")
            return view
        }
        return nil
    }
    
}
