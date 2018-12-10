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
    private(set) public var imageURL: String
    private(set) public var latitude: Double
    private(set) public var longitude: Double
    private(set) public var likes: Int
    
    init(name: String, address: String, imageURL: String, latitude: Double, longitude: Double, likes: Int) {
        self.name = name
        self.address = address
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.likes = likes
    }
}
