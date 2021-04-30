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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        title = ""
        
        let searchVC = SearchViewController()
        searchVC.delegate = self
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }

    func searchViewController(_ vc: SearchViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?) {
        print(coordinates as Any)
        
        // Make sure we have valid coordinates
        guard let existingCoordinates = coordinates else {
            return
        }
        // dismiss the panel after searching and zooming to pinpoint
        panel.move(to: .tip, animated: true)
        
        // remove all pin if any
        mapView.removeAnnotations(mapView.annotations)
        
        // make a new pin point on map
        let pin = MKPointAnnotation()
        pin.coordinate = existingCoordinates
        mapView.addAnnotation(pin)
        
        mapView.setRegion(MKCoordinateRegion(
            center: existingCoordinates,
            span: MKCoordinateSpan(
                latitudeDelta: 0.8,
                longitudeDelta: 0.8
            )
        ),
        animated: true)
    }
}

