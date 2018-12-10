//
//  RestaurantCell.swift
//  ios-testapp
//
//  Created by Reden John Zarra on 08/12/2018.
//  Copyright © 2018 Reden John Zarra. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    let restoImage = UIImageView()
    let restoName = UILabel()
    let restoLikes = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        restoImage.backgroundColor = UIColor.blue
        restoImage.translatesAutoresizingMaskIntoConstraints = false
        restoName.translatesAutoresizingMaskIntoConstraints = false
        restoLikes.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(restoImage)
        contentView.addSubview(restoName)
        contentView.addSubview(restoLikes)
        
        let viewsDict = [
            "image" : restoImage,
            "name" : restoName,
            "likes" : restoLikes
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(50)]", options: [], metrics: nil, views: viewsDict))
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[restoPhoneNumber]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name]-[likes]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name]-[image(50)]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likes]-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
