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
        
        let url  = "http://ouprdwinp.bkt.clouddn.com/%E6%B5%B7%E8%B4%BC%E7%8E%8B%E7%B2%BE%E5%BD%A9%E5%89%AA%E8%BE%91.mp4"
        self.videoPlayer.playConfig(url, view: self.videoPlayBGView)
        
        self.view.addSubview(self.tabView)
    }
    
    func videoPlayerDidBackButtonClick() {
        
        _isHalfScreen = !_isHalfScreen
        debugPrint("-----------:\(_isHalfScreen)")
        if _isHalfScreen == true {
            
            UIDevice.current.setValue(NSNumber.init(value: 3), forKey: "orientation")
            UIDevice.current.setValue(NSNumber.init(value: 1), forKey: "orientation")
            UIView.animate(withDuration: 0.5, animations: { 
                self.videoPlayBGView.frame = CGRect.init(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.width*0.6)
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
                self.videoPlayBGView.frame = CGRect.init(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.width*0.6)
                
            })
        }else{
            UIDevice.current.setValue(NSNumber.init(value: 1), forKey: "orientation")
            UIDevice.current.setValue(NSNumber.init(value: 3), forKey: "orientation")
            UIView.animate(withDuration: 0.5, animations: {
                self.videoPlayBGView.frame = self.view.bounds
            })

        }
        let y = self.videoPlayBGView.frame.maxY
        self.tabView.frame = XCGRect(0, y, SCREEN_WIDTH, SCREEN_HEIGH-y)
        self.navigationController?.navigationBar.isHidden = !_isHalfScreen
        self.videoPlayer.fullScreen(!_isHalfScreen)
    }
    
    lazy var videoPlayer: VideoPlayer = {
        let v = VideoPlayer.init()
        v.delegate = self
        return v
    }()
    
    lazy var videoPlayBGView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.width*0.6))
        self.view.addSubview(view)
        
        return view
    }()
    
    
    lazy var tabView: UITableView = {
        let y = self.videoPlayBGView.frame.maxY
        let t = UITableView.init(frame: XCGRect(0, y, SCREEN_WIDTH, SCREEN_HEIGH-y), style: .grouped)
        t.delegate = self
        t.dataSource = self
        t.tableFooterView = UIView.init()
        let l = UILabel.init(frame: XCGRect(0, 0, SCREEN_WIDTH, 40))
        l.text = "在开始编辑此文件时，Android Studio 会提示当前工程还未配置 Kotlin，根据提示完成操作即可，或者可以在菜单栏中选择 Tools"
        l.font = UIFont.systemFont(ofSize: 15)
        l.numberOfLines = 0
        t.tableHeaderView = l
        return t
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

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell")
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "ViewCell")
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
    
}

