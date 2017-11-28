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
            mapView.settings.zoomGestures = false
            mapView.settings.rotateGestures = false
            mapView.delegate = self
            
        }
        
    }
    
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private var overlay: UIView!
    
    private var shouldDispatchCar = true
    
    private lazy var socket: SocketIOClient = {
        
        return socketManager.defaultSocket
        
    }()
    
    private lazy var socketManager: SocketManager = {
        
        return SocketManager(socketURL: URL(string:"https://protected-ocean-43147.herokuapp.com")!, config: [.log(true), .compress])
        
    }()
    
    private let hotspots: [Hotspot] = [
        Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.039589, longitude: -118.245151)),
        Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.040318, longitude: -118.242125)),
        Hotspot(coordinate: CLLocationCoordinate2D(latitude: 34.037411, longitude: -118.244990))
    ]
    
    private var eventsViewController: EventsViewController {
        
        for viewController in childViewControllers {
            
            if let eventsViewController = viewController as? EventsViewController {
                
                return eventsViewController
                
            }
            
        }
        
        return EventsViewController()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        eventsViewController.delegate = self
        
        socket.connect()
        
        NotificationCenter.default.post(name: NSNotification.Name("loadCars"), object: nil, userInfo: ["numberOfCars": 3])
        NotificationCenter.default.addObserver(self,
            selector: #selector(allCarsDispatched),
            name: NSNotification.Name("allCarsDispatched"),
            object: nil
        )
        
    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let markerImageTemplateView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        markerImageTemplateView.layer.cornerRadius = markerImageTemplateView.frame.width / 2
        markerImageTemplateView.backgroundColor = .orange
        
        let markerImage = UIImage(view: markerImageTemplateView)
        
        mapView.clear()
        mapView.camera = GMSCameraPosition.camera(withLatitude: 34.0391623, longitude: -118.2435846, zoom: 18.0)
        
        for hotspot in hotspots {
            
            let marker = GMSMarker()
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.position = hotspot.coordinate
            marker.icon = markerImage
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
    
}

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        guard shouldDispatchCar else {
            
            return
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("carDispatched"), object: nil)
        
        let markerImageTemplateView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 175, height: 175)))
        markerImageTemplateView.layer.cornerRadius = markerImageTemplateView.frame.width / 2
        markerImageTemplateView.backgroundColor = UIColor(red: 60 / 255, green: 155 / 255, blue: 215 / 255, alpha: 0.4)
        
        let car = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
        car.image = #imageLiteral(resourceName: "theOtherCar")
        car.center = markerImageTemplateView.center
        
        markerImageTemplateView.addSubview(car)
        
        let markerImage = UIImage(view: markerImageTemplateView)
        
        let marker = GMSMarker()
        marker.position = coordinate
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.isDraggable = true
        marker.icon = markerImage
        marker.map = mapView
        
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
    
}

extension ViewController: EventsViewControllerDelegate {
    
    func closedTappedInEventsViewController(_ eventsViewController: EventsViewController) {
        
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
