//
//  CrashNotification.swift
//  HondaHelp
//
//  Created by Bryan Norden on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import Alamofire
import Foundation

class CrashNotification {
    
    // MARK: - Send crash notification
    
    func send(latitude: Double, longitude: Double, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        
        guard latitude > 0, longitude > 0 else {
            
            failure(NSError(domain: "", code: 404, userInfo: nil))
            return
        }
        
        let body = [
            "lat": latitude,
            "long": longitude
        ]
        
        if let serializedBodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []) {
            
            var request = URLRequest(url: URL(string: "")!)
            request.httpMethod = "POST"
            request.httpBody = serializedBodyData
            
            Alamofire.request(request).validate().responseJSON { response in
                
                print(response)
                
                switch response.result {
                    
                case .success:
                    print("Validation Successful")
                    success()
                case .failure(let error):
                    print(error)
                    failure(error)
                }
                
            }
            
        } else {
            failure(NSError(domain: "", code: 500, userInfo: nil))
        }
    }
    
}
