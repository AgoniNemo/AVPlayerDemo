//
//  DownloadManager.swift
//  AVFoundationDemo
//
//  Created by Mjwon on 2017/9/26.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import Foundation
import UIKit


protocol DownloadManagerDelegate:class {
    
    /** 没有完整的缓存文件，告诉播放器自己去用 网络地址 进行播放 */
    func didNoCacheFile(_ manager:DownloadManager)->Void
    
    /** 已经存在下载好的这个文件了，告诉播放器可以直接利用filePath播放 */
    func didFileExisted(_ manager:DownloadManager,_ filePath:String) -> Void
    
    /** 开始下载数据(包括长度和类型) */
    func didStartReceive(_ manager:DownloadManager,_ videoLength:Int) -> Void
    
    /** 正在下载 */
    func didReceiveManager(_ manager:DownloadManager,_ progress:CGFloat) -> Void

    /** 完成下载 */
    func didFinishLoading(_ manager:DownloadManager,_ filePath:String) -> Void

    func didFailLoading(_ manager:DownloadManager,_ errorCode:Error) -> Void

}

class DownloadManager {
    
    weak var delegate:DownloadManagerDelegate?
    
    init(_ videoUrl:String,_ delegate:DownloadManagerDelegate) {
        self.delegate = delegate
        
    }
    
    func start() -> Void {
        
    }
    
    func suspend() -> Void {
        
    }
    
    func cancel() -> Void {
        
    }
    
    
}
