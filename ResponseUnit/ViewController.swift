//
//  ViewController.swift
//  ResponseUnit
//
//  Created by Bryan Norden on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import CoreLocation
import GoogleMaps
import MapKit
import UIKit

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
    
    private let kLatitude = 34.043114
    
    private let kLongitude = -118.244357
    
    // MARK: - UIView

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: kLatitude, longitude: kLongitude, zoom: mapZoomLevel)
        
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
 
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
    
        socket.on("newAssignment") { [weak self] data, ack in
            
            guard let `self` = self else {
                return
            }
            
            guard let vehicleAssignment = data[0] as? [String: Any] else { return }
            
            let newAssistZone: AssistZone = AssistZone(latitude: vehicleAssignment["latitude"] as! CLLocationDegrees, longitude:vehicleAssignment["longitude"] as! CLLocationDegrees )
            
            self.recieved(newAssistZone)
        }
        
        socket.on("newVehicleAccident") { [weak self] data, ack in
            
            guard let `self` = self else {
                return
            }
            
            guard let newIncident = data[0] as? [String: Any] else { return }
            
            let incident: Incident = Incident(latitude: newIncident["latitude"] as! CLLocationDegrees, longitude: newIncident["longitude"] as! CLLocationDegrees)
            
            self.incidents.removeAll()
            self.incidents.append(incident)
            
            self.recieved(incident)
            
        }
        
        socket.connect()
        
    }

}

// MARK: - UI Updates

extension ViewController {
    
    private func recieved(_ newAssistZone: AssistZone) {
        
        activeAssistZone = newAssistZone
        
        let alertController = UIAlertController(title: "New Assist Zone", message: "You have been assigned to a new Assist Zone", preferredStyle: .alert)
        
        let showNewZoneAction =  UIAlertAction(title: "Show Me", style: .default, handler: { (alert: UIAlertAction!) in
            self.updateMapViewWith(newAssistZone)
        })
        
        alertController.addAction(showNewZoneAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func recieved(_ newIncident: Incident) {
        
        
        // TODO: Handle new incident notification and update UI
        
        print(newIncident)
        
        newIncidentsButton.setBackgroundImage(#imageLiteral(resourceName: "help_ac_red"), for: .normal)
        
        incidents.append(newIncident)
        
        updateMapWithNewIncident()
        
    }
    
    private func updateMapViewWith(_ newAssistZone: AssistZone) {
        
        self.mapView.clear()
        
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
        activeAssistZoneMarker.iconView = markerImageTemplateView
        
        activeAssistZoneMarker.isDraggable = false
        activeAssistZoneMarker.map = mapView
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: newAssistZone.location.latitude, longitude: newAssistZone.location.longitude, zoom: mapZoomLevel)
    }
    
    private func updateMapWithNewIncident() {
        
        if incidents.count > 1 {
            
            for (index, incident) in incidents.enumerated() {
                
                if index != incidents.count - 1 {
                    
                    let markerToRemove = GMSMarker(position: incident.location)
                    markerToRemove.map = nil
                    
                }
            }
            
        }
        
        if let incident = incidents.last { // TODO: Update to be more dynamic
            
            newIncidentsButton.setBackgroundImage(#imageLiteral(resourceName: "help_in_red"), for: .normal)
            
            let marker = GMSMarker(position: incident.location)
            marker.icon = #imageLiteral(resourceName: "incidentIcon")
            marker.appearAnimation = .pop
            marker.map = mapView
            
            mapView.camera = GMSCameraPosition.camera(withLatitude:  incident.location.latitude, longitude:  incident.location.longitude, zoom: mapZoomLevel)
            
        }
        
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

// MARK: - GMSMapViewDelegate

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let alertController = UIAlertController(title: "", message: "Do you want to navigate to your assist zone?", preferredStyle: .alert)
        
        let navigateAction =  UIAlertAction(title: "YES", style: .default, handler: { (alert: UIAlertAction!) in
            
            let placeMark = MKPlacemark(coordinate: marker.position)
            
            let directionsRequest = MKDirectionsRequest()
            directionsRequest.destination = MKMapItem(placemark: placeMark)
            directionsRequest.transportType = .automobile
            
            MKMapItem.openMaps(with: [directionsRequest.destination!], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            
        })
        
        let cancelAction =  UIAlertAction(title: "NO", style: .cancel, handler: nil)
        
        alertController.addAction(navigateAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        return true
        
    }
    
}

// MARK: - IBAction

extension ViewController {
 
    @IBAction private func showCurrentAssistZone(_ sender: UIButton) {
        
        if activeAssistZone != nil {
            
            mapView.camera = GMSCameraPosition.camera(withLatitude: (activeAssistZone?.location.latitude)!, longitude: (activeAssistZone?.location.longitude)!, zoom: mapZoomLevel)
            
        } else {
    
            self.updateMapViewWith(AssistZone(latitude: kLatitude, longitude: kLongitude))
            
        }
        
    }
    
    @IBAction private func showActiveIncidents(_ sender: UIButton) {
        
        if incidents.count > 0 {
            updateMapWithNewIncident()
        } else {
            let alertController = UIAlertController(title: "", message: "No active incidents", preferredStyle: .alert)
            
            let cancelAction =  UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
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
