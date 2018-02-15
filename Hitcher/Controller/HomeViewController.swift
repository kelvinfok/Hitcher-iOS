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
