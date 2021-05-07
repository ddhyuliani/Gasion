//
//  LocationManager.swift
//  MapTest
//
//  Created by Dian Dinihari on 27/04/21.
//

import Foundation
import CoreLocation

struct Location {
    let title: String
    let coordinates: CLLocationCoordinate2D?
    let loc : CLLocation?
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let manager = CLLocationManager()
    
    public var startLocCoordinates  : CLLocation?
    public var startLocName = ""
    public var destLocCoordinates  : CLLocation?
    public var destLocName = ""
    
    public var distance : Double = 0.00
    
    var completion: ((CLLocation) -> Void)?
    
    public func getUserLocation(completion: @escaping (CLLocation) -> Void) {
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        startLocCoordinates = manager.location
    }
    
    public func convertUserLocation (with location: CLLocation, completion: @escaping ((String?)-> Void)){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { (placemarks, error) in
            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            print(place)
            
            var name = ""
            
            if let locality = place.locality {
                name += locality
            }
            if let adminRegion = place.administrativeArea {
                name += ", \(adminRegion)"
            }
            
            self.startLocName = name
            completion(name)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
        
        completion?(firstLocation)
        manager.stopUpdatingLocation() 
    }
    
    public func findLocation(with query:String, completion: @escaping (([Location]) -> Void)) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(query) { places, error in
            guard let places = places, error == nil else {
                completion([])
                return
            }
            
            let models: [Location] = places.compactMap({ place in
                
                var name = ""
                if let locationName = place.name {
                    name += locationName
                }
                if let adminRegion = place.administrativeArea {
                    name += ", \(adminRegion)"
                }
                if let locality = place.locality {
                    name += ", \(locality)"
                }
                print("\n\(place)\n")
                
                let result = Location(
                    title: name,
                    coordinates: place.location?.coordinate,
                    loc: place.location
                )
                return result
            })
            
            completion(models)
        }
    }
}
