//
//  VideoPlayer.swift
//  AVFoundationDemo
//
//  Created by Mjwon on 2017/9/25.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@objc protocol VideoPlayerDelegate {
    
    @objc optional func videoPlayerDidBackButtonClick() -> Void
    @objc optional func videoPlayerDidFullScreenButtonClick() -> Void
}

class VideoPlayer:NSObject,DownloadManagerDelegate {
    
    weak var delegate:VideoPlayerDelegate?
    
    var showTopControl:Bool = true    //显示顶部控制视频界面view   default is YES
    var showBototmControl:Bool = true //显示底部控制视频界面view   default is YES
    var _mute:Bool = false
    
    // 静音 default is NO
    var mute:Bool?{
    
        set(m){
            _mute = m!
            self.player?.isMuted = _mute
        }
        
        get{
            return self.mute
        }
    }
    
    var stopWhenAppDidEnterBackground:Bool = true // default is YES
    
    // 可给定video尺寸大小,若尺寸超过view大小时作截断处理
    var videoSize:CGSize?{
        set(v){
            if (self.currentPlayerLayer != nil) {
                self.changePlayerLayerFrame(v!)
            }
        }
        get{ return self.videoSize }
    }
    
    private var manager:DownloadManager?;       //数据下载器
    
    private var  player:AVPlayer?;
    
    private var  currentPlayerItem:AVPlayerItem?;
    
    private var  currentPlayerLayer:AVPlayerLayer?;
    
    private var  backgroundView:UIView?;
    
    private var  videoUrl:String = "";               //视频地址
    
    private var  timeObserve:Any?;   //监听播放进度
    
    private var  duration:CGFloat = 0 //视频时间总长度
    
    //playButtonState 用于 缓冲达到要求值的情况时如果状态是暂停，则不会自动播放
    private var  playButtonState:Bool = true
    private var  isCanToGetLocalTime:Bool = true;     //是否能去获取本地时间（秒）
    private var  localTime:Int = 0;          //当前本地时间
    
    //存储缓冲范围的数组（当拖动滑块时，AVPlayerItem会生成另一个缓冲区域）
    private var  loadedTimeRangeArr:[[String:String]] = Array();
    
    private var  isPlaying:Bool = false          //是否正在播放
    private var  isBufferEmpty:Bool = false       //没有缓冲数据
    private var  lastBufferValue:CGFloat = 0  //记录上次的缓冲值
    private var  currentBufferValue:CGFloat = 0//当前的缓冲值
    
    
    
    func playConfig(_ url:String,view:UIView) -> Void {
        self.videoUrl = url
        
        self.backgroundView = view
        self.videoShowView.frame = view.bounds
        self.videoPlayControl.frame = view.bounds
        
        self.manager = DownloadManager.init(videoUrl, self)
        
    }
    
    func playVideo() -> Void {
        
    }
    
    func pauseVideo() -> Void {
        
    }
    
    func stopVideo() -> Void {
        if self.currentPlayerItem == nil { return }
        self.player?.pause()
        self.player?.cancelPendingPrerolls()
        
        if self.currentPlayerLayer != nil { self.currentPlayerLayer?.removeFromSuperlayer()}
        
        self.removeObserver()
        self.player = nil
        self.currentPlayerItem  = nil
        self.videoPlayControl.removeFromSuperview()
        
        self.loadedTimeRangeArr.removeAll()

    }
    func fullScreen(_ isFullScreen:Bool) -> Void {
        
        
    }
    
    private func getUrlToPlayVideo(_ url:URL) -> Void {
        
        //清空配置
        self.stopVideo()
        
        //初始化一些配置
        self.configureAndNotification()
        
        //创建播放器
        self.currentPlayerItem = AVPlayerItem.init(url: url)
        self.player = AVPlayer.init(playerItem: self.currentPlayerItem)
        self.currentPlayerLayer = AVPlayerLayer.init(player: self.player)
        
        //设置layer的frame
        self.changePlayerLayerFrame(self.videoSize!)
        
        self.addObserver()
    }
    
    private func changePlayerLayerFrame(_ videoSize:CGSize) -> Void {
        
        if videoSize.width > 0 {
            let w = self.videoShowView.bounds.size.width
            let h = w / videoSize.width * videoSize.height;
            
            let y = (self.videoShowView.bounds.size.height - h) * 0.5
            self.currentPlayerLayer?.frame = CGRect.init(x: 0, y: y, width: w, height: h)
            
        }else{
            self.currentPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: self.videoShowView.frame.width, height: self.videoShowView.frame.height)
        }
        
    }
    
    private func addObserver() -> Void {
        self.timeObserve = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main, using: { [weak self](time) in
            let current = CMTimeGetSeconds(time);
            let total = CMTimeGetSeconds((self?.currentPlayerItem?.duration)!);
            let progress = current / total;
            
            self?.videoPlayControl.currentTime = CGFloat(current)
            self?.videoPlayControl.playValue = CGFloat(progress)
            
            // 这里是比较蛋疼的，当拖动滑块到没有缓冲的地方并且没有开始播放时，也会走到这里
            if self?.isCanToGetLocalTime == true{
                self?.localTime = (self?.localTime)!
            }
            let t = self?.getLocalTime()
            
            if (Double(t! - (self?.localTime)!)) > 1.5{
                self?.videoPlayControl.videoPlayerDidBeginPlay()
                self?.isCanToGetLocalTime = true
            }
            
        })
        
        //监听播放器的状态
        self.currentPlayerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        //监听播放器的状态
        self.currentPlayerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        //监听播放器的状态
        self.currentPlayerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        
        
    }
    
    private func configureAndNotification() -> Void {
        
        self.stopWhenAppDidEnterBackground = true;
        self.showTopControl = true;
        self.showBototmControl = true;
        self.playButtonState = true;
        self.isPlaying = false;
        self.isCanToGetLocalTime = true;
        self.loadedTimeRangeArr.removeAll()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // MARK: - DownloadManager delegate
    
    func didNoCacheFile(_ manager: DownloadManager) {
        let url = URL.init(string: self.videoUrl)
        self.getUrlToPlayVideo(url!)
    }
    
    func didFailLoading(_ manager: DownloadManager, _ errorCode: Error) {
        
    }
    
    func didFileExisted(_ manager: DownloadManager, _ filePath: String) {
        let url = URL.init(fileURLWithPath: self.videoUrl)
        self.getUrlToPlayVideo(url)
    }
    
    func didReceiveManager(_ manager: DownloadManager, _ progress: CGFloat) {
        
    }
    
    func didStartReceive(_ manager: DownloadManager, _ videoLength: Int) {
        
    }
    
    func didFinishLoading(_ manager: DownloadManager, _ filePath: String) {
        
    }
    
    // MARK: - NSNotification
    
    @objc func playerItemDidPlayToEnd(_ notification:Notification) -> Void {
        self.player?.seek(to: CMTime.init(value: 0, timescale: 0), completionHandler: { [weak self](b) in
            self?.player?.play()
        })
    }
    
    @objc func appDidEnterBackground() -> Void {
        
    }

    @objc func appDidEnterForeground() -> Void {
        
    }
    
    func seekToTimePlay(_ time:CGFloat) -> Void {
        if self.player != nil {
            self.player?.pause()
        }
        self.loadedTimeRangeArr.append(self.getLoadedTimeRange())
        let isShowActivity = self.judgeLoadedTimeIsShowActivity(Float(time))
        
        if isShowActivity {
            self.videoPlayControl.videoPlayerDidLoading()
        }
        self.isCanToGetLocalTime = true
        
        self.player?.seek(to: CMTimeMake(Int64(time), 1), completionHandler: {[weak self] (finished) in
            self?.play()
        })
        
    }
    
    func play() -> Void {
        if self.playButtonState == true {
            self.player?.play()
            self.videoPlayControl.playerControlPlay()
        }
    }
    
    func judgeLoadedTimeIsShowActivity(_ time:Float) -> Bool {
        
        var show = true
        
        for timeRangeDic in self.loadedTimeRangeArr {
            let start = (timeRangeDic["start"]! as NSString).floatValue
            let duration = (timeRangeDic["duration"]! as NSString).floatValue
            
            if ((start < time) && (time < start + duration)) {
                show = true;
                break;
            }
        }
        
        return show
        
    }
    
    
    func getLoadedTimeRange() -> [String:String] {
        
        let loadedTimeRanges = self.currentPlayerItem?.loadedTimeRanges
        let timeRange = loadedTimeRanges?.first?.timeRangeValue
        let startSeconds = CMTimeGetSeconds((timeRange?.start)!);
        let durationSeconds = CMTimeGetSeconds((timeRange?.duration)!);
        
        return ["start":String.init(format: "%.2f", startSeconds),"duration":String.init(format: "%.2f", durationSeconds)]
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
    
    
    // MARK: - removeObserver
    
    private func removeObserver() -> Void {
        if self.timeObserve != nil {
            self.player?.removeTimeObserver(self.timeObserve as Any)
            self.timeObserve = nil
        }
        
        self.currentPlayerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        self.currentPlayerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        self.currentPlayerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        NotificationCenter.default.removeObserver(self)
        self.player?.replaceCurrentItem(with: nil)
    }
    
    // MARK:  LocalTime
    func getLocalTime() -> Int {
        let d = NSDate.init(timeIntervalSince1970: 0)
        let t = fabs(d.timeIntervalSinceNow)
        
        return Int(t)
    }
    
    // MARK: - lazy
    
    // 用于视频显示的View
    lazy var videoShowView: UIView = {
        let v = UIView.init()
        v.layer.masksToBounds = true
        self.backgroundView?.addSubview(v)
        return v
    }()
    
    //用于控制视频播放界面的View
    lazy var videoPlayControl: VideoPlayerController = {
        let v:VideoPlayerController = VideoPlayerController.init(frame: (self.backgroundView?.bounds)!)
        self.backgroundView?.addSubview(v)
        
        //返回
        v.backButtonClick_block = {[weak self] ()-> () in
            self?.delegate?.videoPlayerDidBackButtonClick!()
        }
        
        //全屏
        v.fullScreenButtonClick_block = {[weak self] ()-> () in
            self?.delegate?.videoPlayerDidFullScreenButtonClick!()
        }
        
        v.playButtonClick_block = {[weak self] (b)-> () in
            
            if b == true {
                self?.player?.play()
            }else{
                self?.player?.pause()
            }
            self?.playButtonState = !(self?.playButtonState)!;

        }
        
        v.sliderTouchEnd_block = {[weak self] (t)-> () in
            self?.seekToTimePlay(t)
        }
        
        v.fastFastForwardAndRewind_block = {[weak self] (t)-> () in
            self?.seekToTimePlay(t)
        }
        
        return v
    }()
    
    
}
