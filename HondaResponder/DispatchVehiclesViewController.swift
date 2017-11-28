//
//  DispatchVehiclesViewController.swift
//  HondaResponder
//
//  Created by Simon Tsai on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import UIKit

class DispatchVehiclesViewController: UIViewController {
    
    @IBOutlet private weak var clearButton: UIButton!
    
    private var numberOfCarsDispatched = 0
    
    private var numberOfCars = 0
    
    private let carWidthAndHeight: CGFloat = 35
    
    private var cars: [UIButton] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(carDispatched), name: NSNotification.Name("carDispatched"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadCars(_:)), name: NSNotification.Name("loadCars"), object: nil)
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        let originY = view.frame.height / 2 - carWidthAndHeight / 2
        
        if numberOfCars == 1 {
            
            let car = cars.first!
            
            let originX = (clearButton.frame.minX + 24) / 2 - car.frame.width / 2
            
            car.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: car.frame.size)
            
        } else {
            
//            let leadingPadding: CGFloat = 40
//
//            let trailingPadding: CGFloat = 56
            
            let leadingPadding: CGFloat = 100
            
            let trailingPadding: CGFloat = 100
            
            let totalSpaceToWorkWith: CGFloat = clearButton.frame.minX - trailingPadding - leadingPadding
            
            let totalWidthOfCars: CGFloat = carWidthAndHeight * CGFloat(numberOfCars)
            
            let numberOfGapsInBetweenCars = numberOfCars - 1
            
            let totalSpacingAvailableForGaps: CGFloat = totalSpaceToWorkWith - totalWidthOfCars
            
            let spacingInBetweenEachCar = totalSpacingAvailableForGaps / CGFloat(numberOfGapsInBetweenCars)
            
            var originX = leadingPadding
            
            for car in cars {
                
                car.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: car.frame.size)
                
                originX = originX + carWidthAndHeight + spacingInBetweenEachCar
                
            }
            
        }
        
    }
    
}

extension DispatchVehiclesViewController {
    
    @objc private func carDispatched() {
        
        guard numberOfCarsDispatched < numberOfCars else {
            
            return
            
        }
        
        numberOfCarsDispatched += 1
        
        if numberOfCarsDispatched == numberOfCars {
            
            NotificationCenter.default.post(name: NSNotification.Name("allCarsDispatched"), object: nil)
            
        }
        
        let car = cars[numberOfCarsDispatched - 1]
        car.isEnabled = false
        
    }
    
    @objc private func loadCars(_ notification: Notification) {
        
        numberOfCarsDispatched = 0
        
        numberOfCars = notification.userInfo?["numberOfCars"] as! Int
        
        for car in cars {
            
            car.removeFromSuperview()
            
        }
        
        cars.removeAll()
        
        for _ in 0..<numberOfCars {
            
            let car = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: carWidthAndHeight, height: carWidthAndHeight)))
            car.setImage(#imageLiteral(resourceName: "theOtherCar"), for: .normal)
            car.setImage(#imageLiteral(resourceName: "car_icon_inac"), for: .disabled)
            car.tintColor = .black
            
            view.addSubview(car)
            
            cars.append(car)
            
        }
        
        let originY = view.frame.height / 2 - carWidthAndHeight / 2
        
        if numberOfCars == 1 {
            
            let car = cars.first!
            
            let originX = (clearButton.frame.minX + 24) / 2 - car.frame.width / 2
            
            car.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: car.frame.size)
            
        } else {
            
//            let leadingPadding: CGFloat = 40
//
//            let trailingPadding: CGFloat = 56
            
            let leadingPadding: CGFloat = 100
            
            let trailingPadding: CGFloat = 100
            
            let totalSpaceToWorkWith: CGFloat = clearButton.frame.minX - trailingPadding - leadingPadding
            
            let totalWidthOfCars: CGFloat = carWidthAndHeight * CGFloat(numberOfCars)
            
            let numberOfGapsInBetweenCars = numberOfCars - 1
            
            let totalSpacingAvailableForGaps: CGFloat = totalSpaceToWorkWith - totalWidthOfCars
            
            let spacingInBetweenEachCar = totalSpacingAvailableForGaps / CGFloat(numberOfGapsInBetweenCars)
            
            var originX = leadingPadding
            
            for car in cars {
                
                car.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: car.frame.size)
                
                originX = originX + carWidthAndHeight + spacingInBetweenEachCar
                
            }
            
        }
        
    }
    
}
