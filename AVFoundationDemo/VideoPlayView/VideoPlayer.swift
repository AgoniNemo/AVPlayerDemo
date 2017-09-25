//
//  VideoPlayer.swift
//  AVFoundationDemo
//
//  Created by Mjwon on 2017/9/25.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import Foundation
import UIKit

@objc protocol VideoPlayerDelegate {
    
    @objc optional func videoPlayerDidBackButtonClick() -> Void
    @objc optional func videoPlayerDidFullScreenButtonClick() -> Void
}

class VideoPlayer {
    
    weak var delegate:VideoPlayerDelegate?
    
    var showTopControl:Bool = true    //显示顶部控制视频界面view   default is YES
    var showBototmControl:Bool = true //显示底部控制视频界面view   default is YES
    
    var mute:Bool = false  // 静音 default is NO
    
    var stopWhenAppDidEnterBackground:Bool = true // default is YES
    
    var videoSize:CGSize?; // 可给定video尺寸大小,若尺寸超过view大小时作截断处理
    
    
    
    func playConfig(_ url:String,view:UIView) -> Void {
        
    }
    
    func playVideo() -> Void {
        
    }
    
    func pauseVideo() -> Void {
        
    }
    
    func stopVideo() -> Void {
        
    }
    func fullScreen(_ isFullScreen:Bool) -> Void {
        
        
    }
    
    
    
}
