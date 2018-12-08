//
//  Restaurant.swift
//  ios-testapp
//
//  Created by Reden John Zarra on 06/12/2018.
//  Copyright © 2018 Reden John Zarra. All rights reserved.
//

import Foundation

struct Restaurant {
    private(set) public var name: String
    private(set) public var address: String
    private(set) public var phoneNumber: String
    private(set) public var latitude: Double
    private(set) public var longitude: Double
    
    init(name: String, address: String, phoneNumber: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.latitude = latitude
        self.longitude = longitude
    }
}
