//
//  ViewController.swift
//  ResponseUnit
//
//  Created by Bryan Norden on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import CoreLocation
import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    @IBOutlet private weak var mapView: GMSMapView!
    
    @IBOutlet private weak var newIncidentsButton: UIButton!
    
    private let locationManager = CLLocationManager()
    
    private lazy var socket: SocketIOClient = {
        
        return socketManager.defaultSocket
        
    }()
    
    private lazy var socketManager: SocketManager = {
        
        return SocketManager(socketURL: URL(string:"https://protected-ocean-43147.herokuapp.com")!, config: [.log(true), .compress])
        
    }()
    
    private var incidents: [Incident] = []
    
    private var activeAssistZone: AssistZone?
    
    private let mapZoomLevel = Float(18)
    
    // MARK: - UIView

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: 34.0403207, longitude: -118.2717511, zoom: mapZoomLevel)
        
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(recievedNewIncident),
            name: NSNotification.Name("NewIncidentNotification"),
            object: nil
        )
 
        // TODO: Remove me when incident is hooked up
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.sendNewIncidentNotification), userInfo: nil, repeats: false)
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
    
        socket.on("newAssignment") { [weak self] data, ack in
            
            guard let `self` = self else {
                return
            }
            
            guard let vehicleAssignment = data[0] as? [String: Any] else { return }
            
            let newAssistZone: AssistZone = AssistZone(latitude: vehicleAssignment["latitude"] as! Double, longitude:vehicleAssignment["longitude"] as! Double )
            
            self.mapView.clear()
            
            self.updateMapViewWith(newAssistZone)
        }
        
        socket.on("newIncident") {data, ack in
            
            guard let newIncident = data[0] as? [String: Any] else { return }
            
            let incident: Incident = Incident(latitude: newIncident["latitude"] as! Double, longitude: newIncident["longitude"] as! Double )

        }
        
        socket.connect()
        
    }
    
    // FIXME: Temporary until I get real call from server
    @objc private func sendNewIncidentNotification() {
        
        let newIncident = Incident(latitude: 34.040667, longitude: -118.268093)
        
        NotificationCenter.default.post(name: NSNotification.Name("NewIncidentNotification"), object: nil, userInfo: ["incident" : newIncident])
        
    }

}

// MARK: - UI Updates

extension ViewController {
    
    private func recieved(newAssistZone: AssistZone) {
        
        activeAssistZone = newAssistZone
        
        let alertController = UIAlertController(title: "New Assist Zone", message: "You have been assigned to a new Assist Zone", preferredStyle: .alert)
        
        let showNewZoneAction =  UIAlertAction(title: "Show Me", style: .default, handler: { (alert: UIAlertAction!) in
            self.updateMapViewWith(newAssistZone)
        })
        
        alertController.addAction(showNewZoneAction)
        
    }
    
    @objc private func recievedNewIncident(_ notification: NSNotification) {
        
        if let newIncident = notification.userInfo?["incident"] as? Incident {
            
            // TODO: Handle new incident notification and update UI
            
            print(newIncident)
            
            newIncidentsButton.setTitle("1", for: .normal)
            
            incidents.append(newIncident)
            
        }
    }
    
    private func updateMapViewWith(_ newAssistZone: AssistZone) {
        
        let markerImageTemplateView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 175, height: 175)))
        markerImageTemplateView.layer.cornerRadius = markerImageTemplateView.frame.width / 2
        markerImageTemplateView.backgroundColor = UIColor(red: 60 / 255, green: 155 / 255, blue: 215 / 255, alpha: 0.4)
        let imageViewSize = CGFloat(40)
        let halfImaveViewSize = imageViewSize / 2
        
        let responderImageView = UIImageView(frame: CGRect(x: markerImageTemplateView.frame.width / 2 - halfImaveViewSize, y:markerImageTemplateView.frame.height / 2 - halfImaveViewSize, width: imageViewSize, height: imageViewSize))
        responderImageView.image = #imageLiteral(resourceName: "responderUnitIcon")
        markerImageTemplateView.addSubview(responderImageView)
        
        let testLocation = CLLocationCoordinate2D(latitude: newAssistZone.location.latitude, longitude: newAssistZone.location.longitude)
        let activeAssistZoneMarker = GMSMarker(position: testLocation)
        activeAssistZoneMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        activeAssistZoneMarker.iconView = markerImageTemplateView
        
        activeAssistZoneMarker.isDraggable = false
        activeAssistZoneMarker.map = mapView
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: newAssistZone.location.latitude, longitude: newAssistZone.location.longitude, zoom: mapZoomLevel)
    }
    
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }

    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            
            let location = locations.first
            
            mapView.camera = GMSCameraPosition(target: (location?.coordinate)!, zoom: mapZoomLevel, bearing: 0, viewingAngle: 0)

            locationManager.stopUpdatingLocation()
        }
        
    }
    
}

// MARK: - IBAction

extension ViewController {
 
    @IBAction private func showCurrentAssistZone(_ sender: UIButton) {
        
        if activeAssistZone != nil {
            
            mapView.camera = GMSCameraPosition(target: (activeAssistZone!.location), zoom: mapZoomLevel, bearing: 0, viewingAngle: 0)
            
        } else {
    
            activeAssistZone = AssistZone(latitude: 34.0391623, longitude: -118.2435846)
            self.updateMapViewWith(activeAssistZone!)
            
        }
        
    }
    
    @IBAction private func showActiveIncidents(_ sender: UIButton) {
        
        if let incident = incidents.first { // TODO: Update to be more dynamic
            
            let marker = GMSMarker(position: incident.location)
            marker.icon = #imageLiteral(resourceName: "incidentIcon")
            marker.appearAnimation = .pop
            marker.map = mapView
            
            mapView.camera = GMSCameraPosition.camera(withLatitude: marker.position.longitude, longitude: marker.position.longitude, zoom: mapZoomLevel)
            
        }
        
    }
}

// MARK: Extensions

extension UIImage {
    
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.init(cgImage: image!.cgImage!)
        
    }
    
}
