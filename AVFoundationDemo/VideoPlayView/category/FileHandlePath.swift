//
//  FileHandlePath.swift
//  AVFoundationDemo
//
//  Created by Mjwon on 2017/9/25.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import Foundation


extension String{

    static func tempFilePath(fileName name:String) -> String {
        
        // NSHomeDirectory() + "/tmp"
        
        let tmpPath = NSTemporaryDirectory() + "\(name)"

        return tmpPath
    }
    
    static func tempFilePath(urlString url:String) -> String {
        
        guard let name = url.components(separatedBy: "/").last else {
            debugPrint("tempFilePath 出错!\(url)")
            return ""
        }
        
        return self.tempFilePath(fileName:name)
        
    }
    
    static func cacheFilePath(fileName name:String) -> String {
        
        let cachePaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        
        guard let cachePath = cachePaths.first else {
            debugPrint("cacheFilePath 出错!\(name)")
            return ""
        }
        
        let path = cachePath + "/Videos/\(name)"
        return path
        
    }
    
    static func cacheFilePath(urlString url:String) -> String {
        
        
        return self.cacheFilePath(fileName:self.fileName(UrlString: url))
        
    }
    
    static func fileName(UrlString url:String) -> String {
        
        guard let name = url.components(separatedBy: "/").last else {
            debugPrint("fileName 出错!\(url)")
            return ""
        }
        
        return name
    }
    
    
}
