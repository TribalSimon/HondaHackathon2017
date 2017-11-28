//
//  AssistZone.swift
//  ResponseUnit
//
//  Created by Bryan Norden on 11/28/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import CoreLocation

struct AssistZone {
    
    var location: CLLocationCoordinate2D
    
    init(latitude: Double, longitude: Double) {
        
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
    }
    
}
