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
    
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    
    private let hotspots: [Hotspot] = [
        Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0450804, longitude: -118.2265129)),
        Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0421624, longitude: -118.2576791)),
        Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0211174, longitude: -118.2067797)),
        Hotspot(coordinate: CLLocationCoordinate2D(latitude: 33.9938161, longitude: -118.2610674))
    ]
    
    private var eventsViewController: EventsViewController {
        
        for viewController in childViewControllers {
            
            if let eventsViewController = viewController as? EventsViewController {
                
                return eventsViewController
                
            }
            
        }
        
        return EventsViewController()
        
    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        mapView.clear()
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
            insets: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        )!
        
    }
    
}

private extension ViewController {
    
    @IBAction private func openMenu() {
        
        leadingConstraint.constant = 0
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            
            self?.view.layoutIfNeeded()
            
        })
        
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
