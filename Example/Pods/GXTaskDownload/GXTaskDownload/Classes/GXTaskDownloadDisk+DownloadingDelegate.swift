//
//  GXTaskDownloadDisk+DownloadingDelegate.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation

extension GXTaskDownloadDisk: GXDownloadingDelegate {
    
    public func download(_ download: GXDownloading, startError error: GXDownloadingError?) {
        
    }
    
    public func download(_ download: GXDownloading, changedState state: GXDownloadingState) {
        downloadBlock?(1.0,state)
    }
    
    public func download(_ download: GXDownloading, completedWithError error: Error?) {
        downloadBlock?(1.0,self.downloader.state)
    }
    
    public func download(_ download: GXDownloading, didReceiveData data: Data, progress: Float) {
        
        //处理数据
        if #available(iOS 13.4, *) {
            let errorValue = try? diskFile.fileHandle?.seekToEnd()
            try? diskFile.fileHandle?.write(contentsOf: data)
//            print("\(String(describing: errorValue))")
        } else {
            diskFile.fileHandle?.seekToEndOfFile()
            diskFile.fileHandle?.write(data)
//            Fallback on earlier versions
        }
//        print(data)
        downloadBlock?(progress,self.downloader.state)
        
    }
    
}
