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
            mapView.settings.rotateGestures = false
            mapView.delegate = self
            
        }
        
    }
    
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private var overlay: UIView!
    
    private var accidentMarkers: [GMSMarker] = []
    
    private var shouldDispatchCar = true
    
    private var dispatchedCarMarkers: [GMSGroundOverlay] = []
    
    @objc private func clearTapped() {
        
        for marker in dispatchedCarMarkers {
            
            marker.map = nil
            
        }
        
        dispatchedCarMarkers.removeAll()
        
        shouldDispatchCar = true
        
        NotificationCenter.default.post(name: NSNotification.Name("loadCars"), object: nil, userInfo: ["numberOfCars": 5])
        
    }
    
    private lazy var socket: SocketIOClient = {
        
        return socketManager.defaultSocket
        
    }()
    
    private lazy var socketManager: SocketManager = {
        
        return SocketManager(socketURL: URL(string:"https://protected-ocean-43147.herokuapp.com")!, config: [.log(true), .compress])
        
    }()
    
    private var eventsViewController: EventsViewController {
        
        for viewController in childViewControllers {
            
            if let eventsViewController = viewController as? EventsViewController {
                
                return eventsViewController
                
            }
            
        }
        
        return EventsViewController()
        
    }
    
    private func display(_ hotspots: [Hotspot]) {
        
        let markerImageTemplateView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        markerImageTemplateView.layer.cornerRadius = markerImageTemplateView.frame.width / 2
        markerImageTemplateView.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 0.4)
        
        let markerImage = UIImage(view: markerImageTemplateView)
        
        mapView.clear()
        mapView.camera = GMSCameraPosition.camera(withLatitude: 34.043114, longitude: -118.244357, zoom: 14)
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) { [weak self] in
//
//            self?.mapView.animate(toZoom: 18)
//
//        }
        
        for hotspot in hotspots {
            
            let markerOverlay = GMSGroundOverlay(position: hotspot.coordinate, icon: markerImage, zoomLevel: 14)
            markerOverlay.anchor = CGPoint(x: 0.5, y: 0.5)
            markerOverlay.isTappable = false
            markerOverlay.map = mapView
            

//            let marker = GMSMarker()
//            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
//            marker.position = hotspot.coordinate
//            marker.icon = markerImage
//            marker.isTappable = false
//            marker.map = mapView
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        eventsViewController.delegate = self
        
        socket.on("newAccident", callback: { [weak self] data, _ in
            
            if let newAccidentObject = data.first as? [String: Any],
                let latitude = newAccidentObject["latitude"] as? CLLocationDegrees,
                let longitude = newAccidentObject["longitude"] as? CLLocationDegrees {
                
                let accidentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                self?.displayAccident(at: accidentLocation)
                
            }
            
        })
        
        socket.connect()
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: 34.043114, longitude: -118.244357, zoom: 14.0)
        
//        displayAccident(at: CLLocationCoordinate2D(latitude: 34.043114, longitude: -118.244357))
        
        NotificationCenter.default.post(name: NSNotification.Name("loadCars"), object: nil, userInfo: ["numberOfCars": 5])
        NotificationCenter.default.addObserver(self,
            selector: #selector(allCarsDispatched),
            name: NSNotification.Name("allCarsDispatched"),
            object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearTapped),
                                               name: NSNotification.Name("clear"),
                                               object: nil
        )
        
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
            insets: UIEdgeInsets(top: 80, left: 80, bottom: 80, right: 80)
        )!
        
    }
    
}

private extension ViewController {
    
    private func closeMenu() {
        
        leadingConstraint.constant = -eventsViewController.view.frame.width
        
        UIView.animate(
            withDuration: 0.15,
            animations: { [weak self] in
                
                self?.view.layoutIfNeeded()
                
                self?.overlay.backgroundColor = .clear
                
            }, completion: { _ in
                
                self.overlay.isHidden = true
                
            }
        )
        
    }
    
    @objc private func allCarsDispatched() {
        
        shouldDispatchCar = false
        
    }
    
}

private extension ViewController {
    
    @IBAction private func openMenu() {
        
        leadingConstraint.constant = 0
        
        overlay.backgroundColor = .clear
        overlay.isHidden = false
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            
            self?.view.layoutIfNeeded()
            
            self?.overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            
        })
        
    }
    
    private func displayAccident(at coordinate: CLLocationCoordinate2D) {
        
        let accidentImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
        accidentImageView.image = #imageLiteral(resourceName: "accident")
        
        let marker = GMSMarker()
        marker.position = coordinate
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.isDraggable = true
        marker.iconView = accidentImageView
        marker.map = mapView
        
        accidentMarkers.append(marker)
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 18.0)
        
    }
    
}

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        guard shouldDispatchCar else {
            
            return
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("carDispatched"), object: nil)
        
        let markerImageTemplateView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 600, height: 600)))
        markerImageTemplateView.layer.cornerRadius = markerImageTemplateView.frame.width / 2
        markerImageTemplateView.backgroundColor = UIColor(red: 60 / 255, green: 155 / 255, blue: 215 / 255, alpha: 0.4)
        
        let car = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
        car.image = #imageLiteral(resourceName: "theOtherCar")
        car.center = markerImageTemplateView.center
        
        markerImageTemplateView.addSubview(car)
        
        let markerImage = UIImage(view: markerImageTemplateView)
        
        let markerOverlay = GMSGroundOverlay(position: coordinate, icon: markerImage, zoomLevel: 18)
        markerOverlay.anchor = CGPoint(x: 0.5, y: 0.5)
        markerOverlay.map = mapView
        
        dispatchedCarMarkers.append(markerOverlay)
        
//        let marker = GMSMarker()
//        marker.position = coordinate
//        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
//        marker.isDraggable = true
//        marker.icon = markerImage
//        marker.map = mapView
        
        let vehicleAssignmentJSON: [String: Any] = ["carID": 1, "latitude": coordinate.latitude, "longitude": coordinate.longitude]
        
        socket.emit("vehicleAssignment", with: [vehicleAssignmentJSON])
        
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        let vehicleAssignmentJSON: [String: Any] = [
            "carID": 1,
            "latitude": marker.position.latitude,
            "longitude": marker.position.longitude
        ]
        
        socket.emit("vehicleAssignment", with: [vehicleAssignmentJSON])
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if accidentMarkers.contains(marker) {
            
            let carOneAction = UIAlertAction(title: "Car 1", style: .default, handler: { _ in
                
                let vehicleAssignmentJSON: [String: Any] = [
                    "carID": 1,
                    "latitude": marker.position.latitude,
                    "longitude": marker.position.longitude
                ]
                
                self.socket.emit("vehicleAccident", with: [vehicleAssignmentJSON])
                
            })
            
            let carTwoAction = UIAlertAction(title: "Car 2", style: .default, handler: { _ in
                
                let vehicleAssignmentJSON: [String: Any] = [
                    "carID": 1,
                    "latitude": marker.position.latitude,
                    "longitude": marker.position.longitude
                ]
                
                self.socket.emit("vehicleAccident", with: [vehicleAssignmentJSON])
                
            })
            
            let carThreeAction = UIAlertAction(title: "Car 3", style: .default, handler: { _ in
                
                let vehicleAssignmentJSON: [String: Any] = [
                    "carID": 1,
                    "latitude": marker.position.latitude,
                    "longitude": marker.position.longitude
                ]
                
                self.socket.emit("vehicleAccident", with: [vehicleAssignmentJSON])
                
            })
            
            let alertController = UIAlertController(title: "Dispatch", message: "Please choose a car to dispatch.", preferredStyle: .alert)
            alertController.addAction(carOneAction)
            alertController.addAction(carTwoAction)
            alertController.addAction(carThreeAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        
        return true
        
    }
    
}

extension ViewController: EventsViewControllerDelegate {
    
    func closeTappedInEventsViewController(_ eventsViewController: EventsViewController) {
        
        closeMenu()
        
    }
    
    func eventsViewController(_ eventsViewController: EventsViewController, hotspotsRetrieved hotspots: [Hotspot]) {
        
        display(hotspots)
        
        NotificationCenter.default.post(name: NSNotification.Name("loadCars"), object: nil, userInfo: ["numberOfCars": 5])
        
        closeMenu()
        
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

extension UIImage {
    
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.init(cgImage: image!.cgImage!)
        
    }
    
}
