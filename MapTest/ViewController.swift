//
//  ViewController.swift
//  MapTest
//
//  Created by Dian Dinihari on 27/04/21.
//

import UIKit
import MapKit
import FloatingPanel
import CoreLocation

class ViewController: UIViewController, SearchViewControllerDelegate  {
    
    let mapView = MKMapView()
    let panel = FloatingPanelController()
    var userLoc = ""
    
    var currentLoc: CLPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.layoutMargins = UIEdgeInsets (top: 20, left: 20, bottom: 300, right: 20)
        view.addSubview(mapView)
        mapView.showsUserLocation = true
        
        let searchVC = SearchViewController()
        searchVC.delegate = self
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
        
        LocationManager.shared.getUserLocation { [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                
                strongSelf.addMapPin(with: location, searchVC: searchVC)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
    //add mappin and zoom in to current user location
    func addMapPin(with location: CLLocation, searchVC : SearchViewController)  {
        let userPin = MKPointAnnotation()
        
        userPin.coordinate = location.coordinate
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)), animated: true)
        mapView.addAnnotation(userPin)
        
        LocationManager.shared.convertUserLocation(with: location) { [weak self ] locationName in
            
            searchVC.fromField.text = locationName ?? ""
        }
    }

    func searchViewController(_ vc: SearchViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?) {
        print(coordinates as Any)
        
        // Make sure we have valid coordinates
        guard let existingCoordinates = coordinates else {
            return
        }
        // dismiss the panel after searching and zooming to pinpoint
        panel.move(to: .half, animated: true)
        
        // remove all pin if any
        mapView.removeAnnotations(mapView.annotations)
        
        // make a new pin point on map
        let pin = MKPointAnnotation()
        pin.coordinate = existingCoordinates
        mapView.addAnnotation(pin)
        
        mapView.setRegion(MKCoordinateRegion(
            center: existingCoordinates,
            span: MKCoordinateSpan(
                latitudeDelta: 0.1,
                longitudeDelta: 0.1
                )
            ),
        animated: true
        )
    }
}


