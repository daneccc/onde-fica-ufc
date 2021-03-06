//
//  MapViewModel.swift
//  UFCExplorer
//
//  Created by Daniele Cavalcante on 17/05/22.
//

import SwiftUI
import MapKit
import CoreLocation

// all map data goes here ...

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var mapView = MKMapView()
    
    // region ...
    @Published var region : MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -3.746469393680665,
                                       longitude: -38.57421686876706),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    )
    // based on location it will set up ...
    
    // alert ...
    @Published var permissionDenied = false
    
    // map type
    @Published var mapType : MKMapType = .standard

    // SearchText
    @Published var searchTxt = ""

    // searched places
    @Published var places : [Place] = []
    
//    let centers: [Center] = [
//        .init(name: "One", lat: 37.334, long: -122.009),
//        .init(name: "Two", lat: 37.380, long: -122.010),
//    ]
    
    // updating map type
    func updateMapType() {
        if mapType == .standard {
            mapType = .hybrid
            mapView.mapType = mapType
        }
        else {
            mapType = .standard
            mapView.mapType = mapType 
        }
    }
    
    // focus location
    func focusLocation() {
        guard let _ = region else { return }
        
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }

    // search places
    func searchQuery() {

        places.removeAll()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTxt

        // fetch 
        MKLocalSearch(request: request).start { (response, _) in 
            guard let result = response else { return }

            self.places = result.mapItems.compactMap({ (item) -> Place? in 
                return Place(place: item.placemark)
            })
        }
    }
    
    // pick search result
    func selectPlace(place: Place) {
        // showing pin on map
        
        searchTxt = ""
        guard let coordinate = place.place.location?.coordinate else { return }
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.place.name ?? "No name"
        
        mapView.addAnnotation(pointAnnotation)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // checking permissions ...
        
        switch manager.authorizationStatus {
        case .denied:
            // alert
            permissionDenied.toggle()
        case .notDetermined:
            // requesting
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // if permissin given
            manager.requestLocation()
        default:
            ()
            
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // error...
        print(error.localizedDescription)
    }
    
    // getting user region...
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        // updating map ...
        self.mapView.setRegion(self.region, animated: true)
        
        // smooth animations
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
}
