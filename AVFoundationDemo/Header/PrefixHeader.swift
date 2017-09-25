//
//  PrefixHeader.swift
//  IM
//
//  Created by Nemo on 2016/11/6.
//  Copyright © 2016年 Nemo. All rights reserved.
//

import Foundation

import UIKit


let  SCREEN_WIDTH = UIScreen.main.bounds.width

let  SCREEN_HEIGH = UIScreen.main.bounds.height

let  SCREEN = UIScreen.main.bounds


func XLog(_ item: Any...) {
    #if DEBUG
        print(item.last!)
    #endif
}

/// - Parameters:
///   - message: 打印消息
///   - file: 打印所属类
///   - lineNumber: 打印语句所在行数
func XLogLine<T>(message : T, file : String = #file, lineNumber : Int = #line) {
    
    #if DEBUG
        
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName):line:\(lineNumber)]- \(message)")
        
    #endif
}

func XCGRect(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) -> CGRect {
    
    return CGRect(x:x,y :y,width: width,height: height);
}


func RGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat)->UIColor {
    
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a);
}

let LIGHTCOLOR = RGBA(r: 241,g: 241,b: 241,a: 1);

let HOMECOLOR = RGBA(r: 255, g: 154, b: 207, a: 1)


