//
//  ViewController.swift
//  HondaResponder
//
//  Created by Simon Tsai on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import GoogleMaps
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var mapView: GMSMapView! {
        
        didSet {
            
            mapView.mapType = .normal
            
            mapView.settings.compassButton = true
            
        }
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let hotspots: [Hotspot] = [
            Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0450804, longitude: -118.2265129)),
            Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0421624, longitude: -118.2576791)),
            Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0211174, longitude: -118.2067797)),
            Hotspot(coordinate: CLLocationCoordinate2D(latitude: 33.9938161, longitude: -118.2610674))
        ]
        
        mapView.surround(hotspots)
        
        for hotspot in hotspots {
            
            let marker = GMSMarker()
            marker.position = hotspot.coordinate
            marker.map = mapView
            
        }
        
    }
    
}

extension GMSMapView {
    
    func surround(_ hotspots: [Hotspot]) {
        
        let sortedStartingFromNorthMostToSouthMost = hotspots.sorted(by: { lhs, rhs in
            
            return lhs.latitude > rhs.latitude
            
        })
        
        let northMostHotspot = sortedStartingFromNorthMostToSouthMost.first!
        
        let southMostHotspot = sortedStartingFromNorthMostToSouthMost.last!
        
        let sortedStartingFromWestMostToEastMost = hotspots.sorted(by: { lhs, rhs in
            
            return lhs.longitude < rhs.longitude
            
        })
        
        let westMostHotspot = sortedStartingFromWestMostToEastMost.first!
        
        let eastMostHotspot = sortedStartingFromWestMostToEastMost.last!
        
        let southwestMostCoordinate = CLLocationCoordinate2D(latitude: southMostHotspot.latitude, longitude: westMostHotspot.longitude)
        
        let northeastMostCoordinate = CLLocationCoordinate2D(latitude: northMostHotspot.latitude, longitude: eastMostHotspot.longitude)
        
        camera = camera(
            for: GMSCoordinateBounds(coordinate: southwestMostCoordinate, coordinate: northeastMostCoordinate),
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        )!
        
    }
    
}

struct Hotspot {
    
    let coordinate: CLLocationCoordinate2D
    
    var latitude: CLLocationDegrees {
        
        return coordinate.latitude
        
    }
    
    var longitude: CLLocationDegrees {
        
        return coordinate.longitude
        
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        
        self.coordinate = coordinate
        
    }
    
}
