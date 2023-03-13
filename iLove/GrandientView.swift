//
//  GrandientView.swift
//  iLove
//
//  Created by Antonio Alves on 1/12/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class GrandienView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func draw(_ rect: CGRect) {
        let components : [CGFloat] = [0,0,0,0.3,0,0,0,0.7]
        let locations  : [CGFloat] = [0,1]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        let x = bounds.midX
        let y = bounds.midY
        let points = CGPoint(x: x, y: y)
        let radius = max(x,y)
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!, startCenter: points, startRadius: 0, endCenter: points, endRadius: radius, options: .drawsAfterEndLocation)
        
    }
}
