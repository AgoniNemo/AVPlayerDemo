//
//  UIImage + ComPress.swift
//  AVFoundationDemo
//
//  Created by Mjwon on 2017/9/25.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import UIKit


extension UIImage {

    func imageCompress(_ image:UIImage,size:CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let new = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return new!
    }

    class func createImage(_ color:UIColor,_ radius:CGFloat) -> UIImage {
        
        let rect = CGRect.init(x: 0, y: 0, width: radius * 2 + 4, height: radius * 2 + 4)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
        let context = UIGraphicsGetCurrentContext();
        
        context?.setStrokeColor(red: 1.0,green: 1.0,blue: 1.0,alpha: 1.0)//画笔线的颜色
        context?.setFillColor(color.cgColor)//填充颜色
        context?.setLineWidth(4.0)//线的宽度
        context?.addArc(center: CGPoint.init(x: radius + 2, y: radius + 2), radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)//添加一个圆
        context?.drawPath(using: .fillStroke)//绘制路径加填充
        
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img!
        
    }
    
    class func creatImage(_ view:UIView) -> UIImage {
        
        let rect = view.frame
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
        let context = UIGraphicsGetCurrentContext();
        view.layer.render(in: context!)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img!
        
    }
    

}
