//
//  textview.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class textview: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
//        rect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rect(){
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.fillColor = UIColor.red.cgColor
        self.layer.addSublayer(shapeLayer)
        var path: CGMutablePath = CGMutablePath()
        path.move(to: CGPoint(x: 10, y: 10))
//        path.addArc(tangent1End: CGPoint(x: 10, y: 10), tangent2End: CGPoint(x: 30, y: 30), radius: 20)
        path.addArc(center: CGPoint(x: 100, y: 100), radius: 20, startAngle: 0.3, endAngle: 1, clockwise: true)
        path.addLine(to: CGPoint(x: 20, y: self.frame.size.height - 10))
        shapeLayer.path = path
    }
    
        override func draw(_ rect: CGRect) {
                    let context = UIGraphicsGetCurrentContext()
                    context?.move(to: CGPoint(x: 10, y: 10))
                    context?.addArc(tangent1End: CGPoint(x: 10, y: 10), tangent2End: CGPoint(x: 30, y: 30), radius: 20)
                    context?.addLine(to: CGPoint(x: 20, y: rect.size.height - 10))
                    context?.setFillColor(UIColor.blue.cgColor)
                    context?.setStrokeColor(UIColor.red.cgColor)
                    UIColor.red.setFill()
                    UIColor.green.setStroke()
                    context?.closePath()
                    context?.drawPath(using: .fillStroke)
            
        }
}
