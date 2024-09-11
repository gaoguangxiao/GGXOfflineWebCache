//
//  GXDownloading.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/5.
//

import Foundation



//The `GXTaskDownloading` protocol represents a generic downloader that can be used for grabbing a fixed length  file.
public protocol GXDownloading {
    
    // MARK: - Properties
    
    /// A receiver implementing the `DownloadingDelegate` to receive state change, completion, and progress events from the `Downloading` instance.
    var delegate: GXDownloadingDelegate? { get set }
    
    /// A `Int64` representing the total amount of bytes for the entire file
    var totalBytesCount: Int64 { get set }
    
    /// The current progress of the downloader. Ranges from 0.0 - 1.0, default is 0.0.
    var progress: Float { get }
    
    /// The current state of the downloader. See `DownloadingState` for the different possible states.
    var state: GXDownloadingState { get }
    
    /// A `URL` representing the current URL the downloader is fetching. This is an optional because this protocol is designed to allow classes implementing the `Downloading` protocol to be used as singletons for many different URLS so a common cache can be used to redownloading the same resources.
    var url: URL? { get set }
    
    // MARK: - Methods
    
    /// Starts the downloader
    func start()
    
    /// Pauses the downloader
    func pause()
    
    /// Stops and/or aborts the downloader. This should invalidate all cached data under the hood.
    func stop()
}
