//
//  Slider.swift
//  AVFoundationDemo
//
//  Created by Nemo on 2017/9/22.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import UIKit

class Slider: UIControl {

    
    var _frame:CGRect = CGRect()
    
    private var _bufferProgress:CGFloat = 0.0
    private var _value:CGFloat = 0.0
    
    // MARK: 播放进度
    var value:CGFloat?{
    
        set(v){
            let value = self.valid(v!)
            if value != _value {
                _value = value
                self.thumb.center = self.getThumbCenterWithValue(_value)
                self.thumbValueImageView.frame = CGRect(x:0, y:(_frame.size.height - self.trackHeight!) * 0.5, width:value * _frame.size.width, height:self.trackHeight!)
            }
        }
        get{ return self._value }
        
    }
    
    // MARK: 缓冲进度
    var bufferProgress:CGFloat{
        set(progress){
            let b = self.valid(progress)
            if _bufferProgress != b {
                _bufferProgress = b
                self.bufferImageView.frame = CGRect(x:0, y:(_frame.size.height - self.trackHeight!) * 0.5, width:progress * _frame.size.width, height:self.trackHeight!)
            }
        }
        get{            
            return self._bufferProgress
        }
    
    }
    
    // MARK: 轨道高度
    var trackHeight:CGFloat?{
        didSet{
            self.setFrame()
        }
    }
    
    // MARK: 滑块触发大小的宽高
    var thumbTouchSize:CGFloat = 0
    
    // MARK: 滑块可视大小的宽高
    var thumbVisibleSize:CGFloat?{
        didSet{
            self.setFrame()
        }
    }
    
    // MARK: 轨道的颜色
    var trackColor:UIColor?{
        
        set(color){
            self.trackImageView.backgroundColor = color
        }
        get{ return self.trackColor }
    }
    
    
    // MARK: 缓冲的颜色
    var bufferColor:UIColor?{
        
        set(color){
            self.bufferImageView.backgroundColor = color
        }
        
        get{ return self.bufferColor }
    }
    
    // MARK: 播放进度的颜色
    var thumbValueColor:UIColor?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _frame = frame
        self.backgroundColor = UIColor.clear
        self.thumbTouchSize = frame.height
        
        thumbVisibleSize = 10
        trackHeight = 2
        
        self.setFrame()
    }
    
    
    func valid(_ float:CGFloat) -> CGFloat {
        
        var f = float
        if f.isNaN {
            return 0.0
        }
        
        if (f < 0.005) {
            return 0.0
        }else if (f > 0.995) {
            f = 1.0
        }
        return f
    }
    
    func setFrame() -> Void {
        self.trackImageView.frame = CGRect.init(x: 0, y: (_frame.size.height-self.trackHeight!)*0.5, width: _frame.size.width, height: self.trackHeight!)
        
        self.bufferImageView.frame = CGRect.init(x: 0, y: (_frame.size.height-self.trackHeight!)*0.5, width: self.bufferProgress*_frame.size.width, height: self.trackHeight!)
        
        self.thumbValueImageView.frame = CGRect.init(x: 0, y: (_frame.size.height-self.trackHeight!)*0.5, width: self.value!*_frame.size.width, height: self.trackHeight!)
        
        
        self.thumb.frame =  CGRect.init(x: 0, y: 0, width: self.thumbTouchSize, height: self.thumbTouchSize);
        self.thumb.center = self.getThumbCenterWithValue(value!)
        
        self.thumbImageView.frame =  CGRect.init(x: (self.thumbTouchSize - self.thumbVisibleSize!) * 0.5, y: (self.thumbTouchSize - self.thumbVisibleSize!) * 0.5, width: self.thumbVisibleSize!, height: self.thumbVisibleSize!)
        
        
        /**
        debugPrint(self.trackImageView.frame)
        debugPrint(self.bufferImageView.frame)
        debugPrint(self.thumbValueImageView.frame)
        debugPrint(self.thumb.frame)
        debugPrint(self.thumbImageView.frame)
         */
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setThumbImage(thumbImage:UIImage,state:UIControlState) -> Void {
        
        if (state == .normal) {
            self.thumbImageView.image = thumbImage;
            self.thumbImageView.backgroundColor = UIColor.clear;
        }else if (state == .highlighted) {
            self.thumbImageView.highlightedImage = thumbImage;
            self.thumbImageView.backgroundColor = UIColor.clear;
        }
    }
    
    func fullScreenChanged(isFullScreen:Bool) -> Void {
        _frame = self.bounds;
        self.setFrame()
    }
    
    lazy var trackImageView:UIImageView = {
    
       let i = UIImageView()
        i.layer.masksToBounds = true
        i.backgroundColor = UIColor.gray
        self.addSubview(i)
        return i
    }()

    lazy var bufferImageView:UIImageView = {
        
        let b = UIImageView()
        b.layer.masksToBounds = true
        b.backgroundColor = UIColor.white
        self.addSubview(b)
        return b
    }()
    
    lazy var thumbValueImageView:UIImageView = {
        
        let b = UIImageView()
        b.layer.masksToBounds = true
        b.backgroundColor = UIColor.red
        self.addSubview(b)
        return b
    }()
    
    lazy var thumbImageView:UIImageView = {
        
        let t = UIImageView()
        t.layer.masksToBounds = true
        t.backgroundColor = UIColor.white
        self.thumb.addSubview(t)
        return t
    }()
    
    lazy var thumb:UIImageView = {
        
        let t = UIImageView()
        t.layer.masksToBounds = true
        t.isUserInteractionEnabled = false
        t.backgroundColor = UIColor.clear
        self.addSubview(t)
        return t
    }()
    
    func getThumbCenterWithValue(_ value:CGFloat) -> CGPoint {
        
        let x = self.thumbVisibleSize! * 0.5 + (_frame.size.width - self.thumbVisibleSize!) * value
        let y = _frame.size.height * 0.5
        debugPrint("\(x,y,value)")
        return CGPoint.init(x: x, y: y)
    }
    
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self);
        
        if (!self.thumb.frame.contains(location)) {
            return false;
        }
        self.thumbImageView.isHighlighted = true;
        self.sendActions(for: .editingDidBegin);
        
        return true;
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self);
        
        if (location.x <= self.bounds.width + 10 && location.x >= -10) {
            self.thumbImageView.isHighlighted = true;
            self.value = location.x / self.bounds.width;
            debugPrint(self.value!)
            self.sendActions(for: .valueChanged)
        }
        return true;
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.thumbImageView.isHighlighted = false;
        self.sendActions(for: .editingDidEnd)
    }
}
