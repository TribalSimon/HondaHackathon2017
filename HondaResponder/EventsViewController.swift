//
//  EventsViewController.swift
//  HondaResponder
//
//  Created by Simon Tsai on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import CoreLocation
import UIKit

protocol EventsViewControllerDelegate {
    
    func closeTappedInEventsViewController(_ eventsViewController: EventsViewController)
    
    func eventsViewController(_ eventsViewController: EventsViewController, hotspotsRetrieved hotspots: [Hotspot])
    
}

class EventsViewController: UIViewController {
    
    private let titles = ["Basketball", "Concerts", "Football"]
    
    var delegate: EventsViewControllerDelegate?
    
}

private extension EventsViewController {
    
    @IBAction private func closeTapped() {
        
        delegate?.closeTappedInEventsViewController(self)
        
    }
    
}

extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        if let aCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            
            cell = aCell
            
        } else {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.font = UIFont(name: "Helvetical Neue", size: 17)
            
        }
        
        cell.textLabel?.text = titles[indexPath.row]
        
        return cell
        
    }
    
}

extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            delegate?.eventsViewController(self, hotspotsRetrieved: [
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0628, longitude: -118.2731)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0571, longitude: -118.2724)),
               Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0332, longitude: -118.2657)),
               Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0295, longitude: -118.2562)),
               Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0213, longitude: -118.2617)),
               Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0482, longitude: -118.2487)),
               Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0402, longitude: -118.2401)),
               Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0315, longitude: -118.2458)),
               Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0204, longitude: -118.2396))]
            )
            
        } else if indexPath.row == 1 {
            
            delegate?.eventsViewController(self, hotspotsRetrieved: [
                
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0499, longitude: -118.2590)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0332, longitude: -118.2657)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0295, longitude: -118.2562)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0213, longitude: -118.2617)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0543, longitude: -118.2391)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0651, longitude: -118.2363)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0402, longitude: -118.2401)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0315, longitude: -118.2458))]
            )
            
        } else {
            
            delegate?.eventsViewController(self, hotspotsRetrieved: [
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0628, longitude: -118.2731)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0468, longitude: -118.2686)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0499, longitude: -118.2590)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0332, longitude: -118.2657)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0295, longitude: -118.2562)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0213, longitude: -118.2617)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0482, longitude: -118.2487)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0543, longitude: -118.2391)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0651, longitude: -118.2363)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0402, longitude: -118.2401)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0315, longitude: -118.2458)),
                Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.0204, longitude: -118.2396))]
            )
            
        }
        
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 3000)))
//    }
    
}
