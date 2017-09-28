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

class DownloadManager:NSObject,URLSessionDataDelegate {
    
    weak var delegate:DownloadManagerDelegate?
    private var videoUrl:String = ""
    private let fileManager = FileManager.default
    private var fileHandle:FileHandle?
    private var curruentLength:UInt64 = 0
    private var dataTask:URLSessionDataTask?
    
    //定义文件的临时下载路径
    private var videoTempPath:String = ""
    
    //定义文件的缓存路径
    private var videoCachePath:String = ""
    
    init(_ videoUrl:String,_ delegate:DownloadManagerDelegate) {
        super.init()
        
        self.delegate = delegate
        self.videoUrl = videoUrl
        
        self.fileJudge()
    }
    
    private func fileJudge() -> Void {
        let videoName = self.videoUrl.components(separatedBy: "/").last
        self.videoTempPath = String.tempFilePath(fileName: videoName!)
        self.videoCachePath = String.cacheFilePath(fileName: videoName!)
        
        debugPrint("videoTempPath === \(self.videoTempPath)")
        
        
        if self.fileManager.fileExists(atPath: self.videoCachePath) {
            self.delegate?.didFileExisted(self, self.videoCachePath)
        }else{
            if self.fileManager.fileExists(atPath: self.videoTempPath) {
                self.fileHandle = FileHandle.init(forUpdatingAtPath: self.videoTempPath)
                curruentLength = (self.fileHandle?.seekToEndOfFile())!
            }else{
                curruentLength = 0
                fileManager.createFile(atPath: self.videoTempPath, contents: nil, attributes: nil)
                fileHandle = FileHandle.init(forUpdatingAtPath: self.videoTempPath)
            }
        }
        
    }
    
    func sendHttpRequst() -> Void {
        fileHandle?.seekToEndOfFile()
        let url = URL.init(string: self.videoUrl)
        var request = URLRequest.init(url: url!)
        request.setValue("bytes=\(self.curruentLength)-", forHTTPHeaderField: "Range")
        
        dataTask = self.session.dataTask(with: request)
        
        dataTask?.resume()
        
    }
    
    // MARK: - delegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let http = response as? HTTPURLResponse
        let dic = http?.allHeaderFields
        let content:String = dic?["Content-Range"] as! String
        
        let array = content.components(separatedBy: "/")
        let length = array.last
        
        var videoLength:Int64 = 0
        
        if Int(length!)! == 0 {
            videoLength = (http?.expectedContentLength)!
        }else{
            videoLength = Int64(length!)!
        }
        
        completionHandler(.allow)
        
        
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
    }
    
    
    func start() -> Void {
        debugPrint("---开始---")
    }
    
    func suspend() -> Void {
        debugPrint("---暂停---")
    }
    
    func cancel() -> Void {
        debugPrint("---取消---")
    }
    
    lazy var session: URLSession = {
        let s = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        return s
    }()
    
    
    // MARK: - lazy

    
    
}
