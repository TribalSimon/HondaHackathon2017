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
            
            mapView.isMyLocationEnabled = true
            
            mapView.mapType = .normal
            
            mapView.settings.compassButton = true
            
            mapView.settings.myLocationButton = true
            
            mapView.camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
            
        }
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
    }
    
}

