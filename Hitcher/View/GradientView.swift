//
//  GradientView.swift
//  Hitcher
//
//  Created by Kelvin Fok on 10/2/18.
//  Copyright © 2018 Kelvin Fok. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    let gradient = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientView()
    }
    
    func setupGradientView() {
        gradient.frame = self.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.init(white: 1.0, alpha: 0).cgColor]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations = [0.8, 1.0]
        self.layer.insertSublayer(gradient, at: 0)
        
    }
}
