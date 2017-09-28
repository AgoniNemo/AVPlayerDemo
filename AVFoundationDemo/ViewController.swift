//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by Nemo on 2017/9/22.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import UIKit

class ViewController: UIViewController,VideoPlayerDelegate {

    
    var _isHalfScreen:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoPlayBGView.backgroundColor = UIColor.black
        
        let url  = "http://ouprdwinp.bkt.clouddn.com/%E6%B5%B7%E8%B4%BC%E7%8E%8B%E7%B2%BE%E5%BD%A9%E5%89%AA%E8%BE%91.mp4"
        self.videoPlayer.playConfig(url, view: self.videoPlayBGView)
    }
    
    func videoPlayerDidBackButtonClick() {
        
        _isHalfScreen = !_isHalfScreen
        
        if _isHalfScreen == true {
            
            UIDevice.current.setValue(NSNumber.init(value: 3), forKey: "orientation")
            UIDevice.current.setValue(NSNumber.init(value: 1), forKey: "orientation")
            UIView.animate(withDuration: 0.5, animations: { 
                self.videoPlayBGView.frame = CGRect.init(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.width*0.6)
            })
            self.videoPlayer.fullScreen(!_isHalfScreen)
        }else{
            self.videoPlayer.stopVideo()
            self.dismiss(animated: true, completion: { 
                
            })
        }
        
    }
    
    func videoPlayerDidFullScreenButtonClick() {
        
    }
    
    lazy var videoPlayer: VideoPlayer = {
        let v = VideoPlayer.init()
        v.delegate = self
        return v
    }()
    
    lazy var videoPlayBGView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.width*0.6))
        self.view.addSubview(view)
        
        return view
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

