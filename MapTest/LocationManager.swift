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
}

class LocationManager: NSObject {
    static let shared = LocationManager()
    
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
                    coordinates: place.location?.coordinate
                )
                return result
            })
            completion(models)
        }
    }
}
