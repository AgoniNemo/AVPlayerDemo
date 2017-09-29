//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by Nemo on 2017/9/22.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import UIKit

class ViewController: UIViewController,VideoPlayerDelegate {

    
    var _isHalfScreen:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.videoPlayBGView.backgroundColor = UIColor.black
        
        // http://www.qylsp8.com/file/35993/3/ed5165ea3aa9145c1938/1506774712/mp4/35993.mp4
        let url  = "http://www.qylsp8.com/file/33982/1/56dd1b8810f51a077050/1506774843/mp4/33982.mp4"
        self.videoPlayer.playConfig(url, view: self.videoPlayBGView)
    }
    
    func videoPlayerDidBackButtonClick() {
        
        _isHalfScreen = !_isHalfScreen
        debugPrint("-----------:\(_isHalfScreen)")
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
        
        _isHalfScreen = !_isHalfScreen
        debugPrint("==========:\(_isHalfScreen)")
        if _isHalfScreen == true {
            
            UIDevice.current.setValue(NSNumber.init(value: 3), forKey: "orientation")
            UIDevice.current.setValue(NSNumber.init(value: 1), forKey: "orientation")
            UIView.animate(withDuration: 0.5, animations: {
                self.videoPlayBGView.frame = CGRect.init(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.width*0.6)
            })
        }else{
            UIDevice.current.setValue(NSNumber.init(value: 1), forKey: "orientation")
            UIDevice.current.setValue(NSNumber.init(value: 3), forKey: "orientation")
            UIView.animate(withDuration: 0.5, animations: {
                self.videoPlayBGView.frame = self.view.bounds
            })

        }
        self.navigationController?.navigationBar.isHidden = !_isHalfScreen
        self.videoPlayer.fullScreen(!_isHalfScreen)
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
    
    override var shouldAutorotate: Bool{
        
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
        {
        
//        debugPrint(_isHalfScreen)
        
        if _isHalfScreen{
            return .portrait
        }
        
        return .landscape
        
    }
    deinit {
//        self.videoPlayer.stopVideo()
        debugPrint("释放:\(self)")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

