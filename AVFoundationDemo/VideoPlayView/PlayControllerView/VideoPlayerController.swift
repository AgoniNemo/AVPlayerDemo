//
//  VideoPlayerController.swift
//  AVFoundationDemo
//
//  Created by Mjwon on 2017/9/25.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoPlayerController: UIView,UIGestureRecognizerDelegate {

    private var _currentTime:CGFloat = 0.0
    var currentTime:CGFloat?{
        set(c){
            _currentTime = c!
            if self._sliderIsTouching == false{
                self.currentLabel.text = self.timeFormatted(totalSeconds: Int(c!))
            }
        }
        
        get{ return self._currentTime }
        
    }
    
    var _sliderIsTouching:Bool = false
    var _isToShowControl:Bool = false
    var _isStartPan:Bool = false
    
    var _startPoint:CGPoint = CGPoint.init()
    var _lastPoint:CGPoint = CGPoint.init()
    var _fastCurrentTime:CGFloat = 0
    
    private var _totalTime:CGFloat = 0.0
    var totalTime:CGFloat?{
    
        set(t){
            _totalTime = t!
            self.totalLabel.text = self.timeFormatted(totalSeconds: Int(t!))
        }
        
        get{ return self._totalTime }
    }
    
    private var _playValue:CGFloat = 0.0
    
    //播放进度
    var playValue:CGFloat?{
    
        set(p){
            _playValue = p!
            if self._sliderIsTouching == false{
                self.videoSlider.value = p;
            }
        }
        
        get{ return self._playValue }
    
    }
    
    private var _progress:CGFloat = 0.0
    //缓冲进度
    var progress:CGFloat?{
        set(t){
            _progress = t!
            self.videoSlider.bufferProgress = progress!
        }
        
        get{ return self._progress }
    }
    
    private let TopHeight:CGFloat = 40
    private let BottomHeight:CGFloat = 40
    
    var playButtonClick_block:((Bool)->())?;
    var sliderTouchEnd_block:((CGFloat)->Void)?;
    
    var fastFastForwardAndRewind_block:((CGFloat)->())?;
    
    var backButtonClick_block:(()->(Void))?;
    var fullScreenButtonClick_block:(()->())?;
    
    private var _frame:CGRect = CGRect.init();
    
    private var volumeViewSlider:UISlider?;//控制音量
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _frame = frame
        self.layer.masksToBounds = true
        
        self.setFrame()
        
    }
    
    func setFrame() -> Void {
        self.volumeView.frame = self.bounds;
        
        //全屏的东西
        self.fullScreenView.frame = self.bounds;
        self.fastTimeLabel.frame = self.bounds;
        self.activityView.frame = self.bounds;
        
        self.fullScreenView.addGestureRecognizer(self.tapGesture)
        self.fullScreenView.addGestureRecognizer(self.panGesture)
        
        
        //顶部
        self.topView.frame = CGRect(x:0, y:0, width:_frame.size.width, height:TopHeight);
        self.backButton.frame = CGRect(x:0, y:0, width:40,height: TopHeight);
        self.fullScreenButton.frame = CGRect(x:_frame.size.width - 40, y:0, width:40, height:TopHeight);
        
        
        //低部
        self.bottomView.frame = CGRect(x:0, y:_frame.size.height - BottomHeight, width:_frame.size.width, height:BottomHeight);
        self.playButton.frame = CGRect(x:0, y:0, width:40, height:BottomHeight);
        self.currentLabel.frame = CGRect(x:self.playButton.frame.maxX, y:0, width:50, height:BottomHeight);
        self.totalLabel.frame = CGRect(x:_frame.size.width - 50 - 10, y:0, width:50, height:BottomHeight);
        
        self.videoSlider.frame = CGRect(x:self.currentLabel.frame.maxX + 5, y:0, width:_frame.size.width - self.currentLabel.frame.maxX - self.totalLabel.frame.size.width - 20 , height:BottomHeight);
        
    }
    
    func tapGestureTouch(_ tapGesture:UITapGestureRecognizer) -> Void {
        
        self.hiddenTopViewAndBottomView()
        
    }
    func hiddenTopViewAndBottomView() -> Void {
        
        self.panGesture.isEnabled = _isToShowControl
        var topF:CGRect?
        var botF:CGRect?
        
        if _isToShowControl == true {
            
            topF = CGRect.init(x: 0, y: 0, width: self._frame.width, height: self.TopHeight)
            botF = CGRect.init(x: 0, y: self._frame.size.height - self.BottomHeight, width: self._frame.width, height: self.BottomHeight)
        }else{
            topF = CGRect.init(x: 0, y: -TopHeight, width: _frame.size.width, height: self.TopHeight)
            botF = CGRect.init(x: 0, y: _frame.size.height, width: _frame.size.width, height: self.BottomHeight)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.topView.frame = topF!
            self.bottomView.frame = botF!
        })
        
        _isToShowControl = !_isToShowControl;
        
    }
    
    func panGestureTouch(_ panGestureTouch:UIPanGestureRecognizer) -> Void {
        let touPoint = panGestureTouch.translation(in: self)
        var changeXorY = 0;    //0:X:进度   1:Y：音量
        
        if panGestureTouch.state == .began {
            _startPoint = touPoint;
            _lastPoint = touPoint;
            _isStartPan = true;
            _fastCurrentTime = self.currentTime!;
            changeXorY = 0;
            
        }else if (panGestureTouch.state == .changed){
            let change_X = touPoint.x - _startPoint.x;
            let change_Y = touPoint.y - _startPoint.y;
            
            if (_isStartPan) {
                
                if (fabs(change_X) > fabs(change_Y)) {
                    changeXorY = 0;
                }else{
                    changeXorY = 1;
                }
                _isStartPan = false;
            }
            if (changeXorY == 0) {//进度
                self.fastTimeLabel.isHidden = false;
                
                if (touPoint.x - _lastPoint.x >= 1) {
                    _lastPoint = touPoint;
                    _fastCurrentTime += 2;
                    if (_fastCurrentTime > self.totalTime!) {
                        _fastCurrentTime = self.totalTime!
                    }
                }
                if (touPoint.x - _lastPoint.x <= -1) {
                    _lastPoint = touPoint;
                    _fastCurrentTime -= 2;
                    if (_fastCurrentTime < 0) {
                        _fastCurrentTime = 0;
                    }
                }
                
                let currentTimeString = self.timeFormatted(totalSeconds: Int(_fastCurrentTime))
                let totalTimeString = self.timeFormatted(totalSeconds: Int(totalTime!));
                self.fastTimeLabel.text = "\(currentTimeString)/\(totalTimeString)"
                
            }else{//音量
                if (touPoint.y - _lastPoint.y >= 5) {
                    _lastPoint = touPoint;
                    self.volumeViewSlider?.value -= 0.07;
                }
                if (touPoint.y - _lastPoint.y <= -5) {
                    _lastPoint = touPoint;
                    self.volumeViewSlider?.value += 0.07;
                }
            }

        }else if (panGestureTouch.state == .ended){
        
            self.fastTimeLabel.isHidden = true
            if changeXorY == 0 {
                if self.fastFastForwardAndRewind_block != nil {
                    self.fastFastForwardAndRewind_block!(_fastCurrentTime)
                }
            }
            
        }
    }
    
    func backButtonClick(_ btn:UIButton) -> Void {
        
        if (self.backButtonClick_block != nil) {
            self.backButtonClick_block!()
        }
    }
    
    func fullScreenButtonClick(_ btn:UIButton) -> Void {
        if (self.fullScreenButtonClick_block != nil) {
            self.fullScreenButtonClick_block!()
        }
    }

    func playButtonClick(_ btn:UIButton) -> Void {
        let b:Bool = !btn.isSelected;
        btn.isSelected = b
        
        if (self.playButtonClick_block != nil) {
            self.playButtonClick_block!(b)
        }
    }
    
    /// MARK:拖动中
    func sliderValueChange(_ slider:Slider) -> Void {
        _sliderIsTouching = true
        self.currentLabel.text = self.timeFormatted(totalSeconds: Int(slider.value! * self.totalTime!))
    }
    /// MARK:拖动结束
    func sliderTouchEnd(_ slider:Slider) -> Void {
        
        if (self.sliderTouchEnd_block != nil) {
            self.sliderTouchEnd_block!(slider.value! * self.totalTime!)
        }
        
        _sliderIsTouching = false;
    }

    func videoPlayerDidLoading() -> Void {
        debugPrint("正在播放")
        self.activityView.startAnimating()
    }
    
    func videoPlayerDidBeginPlay() -> Void {
        debugPrint("播放开始")
        self.activityView.stopAnimating()
    }
    
    func videoPlayerDidEndPlay() -> Void {
        debugPrint("播放结束")
    }
    
    func videoPlayerDidFailedPlay() -> Void {
        debugPrint("播放失败")
        self.activityView.stopAnimating()
    }
    
    
    /// MARK:外部方法播放
    func playerControlPlay() -> Void {
        self.playButton.isSelected = true
        self.activityView.isHidden = false
        // 隐藏顶部与底部视图
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.hiddenTopViewAndBottomView()
        }
        
    }
    
    /// MARK:外部方法暂停
    func playerControlPause() -> Void {
        self.playButton.isHidden = true
    }
    
    func fullScreenChanged(_ isFullScreen:Bool) -> Void {
        _frame = self.bounds
        
        self.setFrame()
        
        self.fullScreenButton.isSelected = isFullScreen
        
        self.videoSlider.fullScreenChanged(isFullScreen: isFullScreen)
        
    }
    
    func timeFormatted(totalSeconds:Int) -> String {
        
        let seconds = totalSeconds % 60;
        let minutes = (totalSeconds / 60) % 60;
        let result = String.init(format: "%02d:%02d",minutes, seconds)
                
        return result
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: self.fullScreenView))!{
            return true
        }
        return false
    }
    
    /// MARK:滑动条
    lazy var videoSlider: Slider = {
        let x = self.currentLabel.frame.maxX
        let w = self._frame.size.width - x - self.totalLabel.frame.width - 20
        
        let v:Slider = Slider.init(frame: CGRect.init(x: x + 5, y: 0, width: w, height: self.BottomHeight))
        
        let normalImage = UIImage.createImage(UIColor.red, 5.0)

        let h = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 12, height: 12))
        h.layer.cornerRadius = 6
        h.layer.masksToBounds = true
        h.backgroundColor = UIColor.red
        let highlightImage = UIImage.creatImage(h)
        
        v.setThumbImage(thumbImage: normalImage, state: .normal)
        v.setThumbImage(thumbImage: highlightImage, state: .highlighted)
        
        
        v.trackHeight = 1.5
        v.thumbVisibleSize = 12
        //正在拖动
        v.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
        //拖动结束
        v.addTarget(self, action: #selector(sliderTouchEnd(_:)), for: .editingDidEnd)
        self.bottomView.addSubview(v)
        
        return v
    }()
    
    /// MARK:视频总时间
    private lazy var totalLabel: UILabel = {
        
        let t = UILabel.init()
        t.text = "00:00"
        t.textColor = UIColor.white
        t.textAlignment = .center
        t.font = UIFont.systemFont(ofSize: 14)
        self.bottomView.addSubview(t)
        
        return t
    }()
    
    /// MARK:当前播放时间
    private lazy var currentLabel: UILabel = {
        let c = UILabel.init()
        c.text = "00:00"
        c.textColor = UIColor.white
        c.textAlignment = .center
        c.font = UIFont.systemFont(ofSize: 14)
        self.bottomView.addSubview(c)
        
        return c
    }()
    
    /// MARK:播放/暂停
    private lazy var playButton: UIButton = {
        let p = UIButton.init(type: .custom)
        p.setImage(UIImage.init(named: "video_play@2x.png"), for: .normal)
        p.setImage(UIImage.init(named: "video_pause@2x.png"), for: .selected)
        p.addTarget(self, action: #selector(playButtonClick(_:)), for: .touchUpInside)
        self.bottomView.addSubview(p)
        
        return p
    }()
    
    /// MARK:底部视图
    private lazy var bottomView: UIView = {
        let b = UIView.init()
        b.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.addSubview(b)
        return b
    }()
    
    /// MARK:全屏按钮
    private lazy var fullScreenButton: UIButton = {
        
        let f = UIButton.init(type: .custom)
        f.setImage(UIImage.init(named: "normal_screen@2x.png"), for: .normal)
        f.setImage(UIImage.init(named: "full_screen@2x.png"), for: .selected)
        f.addTarget(self, action: #selector(fullScreenButtonClick(_:)), for: .touchUpInside)
        self.topView.addSubview(f)
        
        return f
    }()
    
    /// MARK:返回
    private lazy var backButton: UIButton = {
        
        let b = UIButton.init(type: UIButtonType.custom)
        b.setImage(#imageLiteral(resourceName: "back.png"), for: .normal)
        b.addTarget(self, action: #selector(backButtonClick(_:)), for: .touchUpInside)
        self.topView.addSubview(b)
        
        return b
    }()
    
    /// MARK:顶部
    private lazy var topView: UIView = {
        let t = UIView.init()
        t.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.addSubview(t)
        return t
    }()
    
    /// MARK:单击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        let t = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureTouch(_:)))
        t.delegate = self
        return t
    }()
    
    /// MARK:滑动手势
    private lazy var panGesture: UIPanGestureRecognizer = {
        let p = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureTouch(_:)))
        return p
    }()
    
    /// MARK:菊花
    private lazy var activityView: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        a.hidesWhenStopped = true
        self.fullScreenView.addSubview(a)
        
        return a
    }()
    
    /// MARK:全屏的一个视图
    private lazy var fullScreenView: UIView = {
        let f = UIView.init()
        self.addSubview(f)
        return f
    }()
    
    
    /// MARK:全屏显示快进快退时的时间进度
    private lazy var fastTimeLabel: UILabel = {
        let f = UILabel.init()
        f.textColor = UIColor.white
        f.font = UIFont.systemFont(ofSize: 30)
        f.textAlignment = .center
        f.isHidden = true
        
        return f
    }()
    
    /// MARK:系统音量控件
    private lazy var volumeView: MPVolumeView = {
        let v = MPVolumeView.init()
        v.sizeToFit()
        
        for view:UIView in v.subviews{
            if (view.description == "MPVolumeSlider"){
                self.volumeViewSlider = view as? UISlider;
                break;
            }
        }
        
        return v
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
