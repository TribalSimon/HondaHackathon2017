//
//  DispatchVehiclesViewController.swift
//  HondaResponder
//
//  Created by Simon Tsai on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import UIKit

class DispatchVehiclesViewController: UIViewController {
    
    @IBOutlet private weak var autoButton: UIButton!
    
    private let car: UIView = {
        
        let car = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
        car.backgroundColor = .black
        
        return car
        
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.addSubview(car)
        
        NotificationCenter.default.addObserver(self, selector: #selector(carDispatched), name: NSNotification.Name("carDispatched"), object: nil)
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        let originX = (autoButton.frame.minX + 24) / 2 - car.frame.width / 2
        let originY = view.frame.height / 2 - car.frame.height / 2
        
        car.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: car.frame.size)
        
    }
    
}

extension DispatchVehiclesViewController {
    
    @objc private func carDispatched() {
        
        car.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
    }
    
}
