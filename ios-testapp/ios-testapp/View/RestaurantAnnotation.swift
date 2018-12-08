//
//  PinAnnotation.swift
//  ios-testapp
//
//  Created by Reden John Zarra on 06/12/2018.
//  Copyright © 2018 Reden John Zarra. All rights reserved.
//

import UIKit
import MapKit

class RestaurantAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    dynamic var coordinate: CLLocationCoordinate2D //cannot be properly set unless dynamic.
    var identifier: String
//
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, identifier: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.identifier = identifier

        super.init()
    }
}
