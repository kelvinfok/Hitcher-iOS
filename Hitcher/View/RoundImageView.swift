//
//  RoundImageView.swift
//  Hitcher
//
//  Created by Kelvin Fok on 11/2/18.
//  Copyright © 2018 Kelvin Fok. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
    
}
