//
//  CircleView.swift
//  devslopes-social
//
//  Created by Joe Rozek on 9/20/17.
//  Copyright © 2017 Joe Rozek. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
