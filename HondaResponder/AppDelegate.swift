//
//  AppDelegate.swift
//  HondaResponder
//
//  Created by Simon Tsai on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import GoogleMaps
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyAA-4RbJWqkjt1mZbZo_AcZqzrGvDHBagA")
        
        return true
        
    }
    
}
