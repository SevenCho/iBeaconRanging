//
//  IconCell.swift
//  iBeaconDemo
//
//  Created by 曹雪松 on 2018/4/27.
//  Copyright © 2018 曹雪松. All rights reserved.
//

import UIKit

class IconCell: UICollectionViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    
    var icon: Icons? {
        didSet {
            guard let icon = icon else { return }
            imgIcon.image = icon.image()
        }
    }
}
