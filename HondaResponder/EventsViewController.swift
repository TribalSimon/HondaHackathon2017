//
//  EventsViewController.swift
//  HondaResponder
//
//  Created by Simon Tsai on 11/27/17.
//  Copyright © 2017 TribalScale. All rights reserved.
//

import UIKit

protocol EventsViewControllerDelegate {
    
    func closeTappedInEventsViewController(_ eventsViewController: EventsViewController)
    
}

class EventsViewController: UIViewController {
    
    private let titles = ["Basketball", "Cars", "Football"]
    
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
            
        }
        
        cell.textLabel?.text = titles[indexPath.row]
        
        return cell
        
    }
    
}
