//
//  EventsViewController.swift
//  HondaResponder
//
//  Created by Simon Tsai on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import UIKit

protocol EventsViewControllerDelegate {
    
    func closedTappedInEventsViewController(_ eventsViewController: EventsViewController)
    
}

class EventsViewController: UIViewController {
    
    var delegate: EventsViewControllerDelegate?
    
}

private extension EventsViewController {
    
    @IBAction private func closeTapped() {
        
        delegate?.closedTappedInEventsViewController(self)
        
    }
    
}
