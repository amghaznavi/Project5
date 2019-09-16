//
//  GridyCreation.swift
//  Gridy
//
//  Created by Am GHAZNAVI on 05/09/2019.
//  Copyright © 2019 Am GHAZNAVI. All rights reserved.
//

import Foundation
import UIKit

// for default image
class Creation {
    var image: UIImage
    static var defaultImage : UIImage {
        return UIImage.init(named: "Placeholder")!
    }
    init() {
        image = Creation.defaultImage
    }
}

// for round corners
class RoundCorner: UIView {
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
}
