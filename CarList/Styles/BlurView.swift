//
//  BlurView.swift
//  CarList
//
//  Created by Иван Медведев on 11/10/2019.
//  Copyright © 2019 Medvedev. All rights reserved.
//

import UIKit

class BlurView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundColor = UIColor(red: 35/255, green: 90/255, blue: 87/255, alpha: 1.0)
        self.insertSubview(blurEffectView, at: 0)
    }
    

}
