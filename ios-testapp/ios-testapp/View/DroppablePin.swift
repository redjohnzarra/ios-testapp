//
//  DroppablePin.swift
//  ios-testapp
//
//  Created by Reden John Zarra on 08/12/2018.
//  Copyright © 2018 Reden John Zarra. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()
    }
}
