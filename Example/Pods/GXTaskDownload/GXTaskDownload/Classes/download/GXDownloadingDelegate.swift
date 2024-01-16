//
//  GXDownloadingDelegate.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/5.
//

import Foundation

/// The `GXDownloadingDelegate` provides an interface for responding to changes
/// to a `GXDownloading` instance. These include whenever the download state
/// changes, when the download has completed (with or without an error), and
/// when the downloader has received data.
public protocol GXDownloadingDelegate {
    /// Triggered when a `Downloading` instance has changed its `Downloading` state during an existing download operation.
    ///
    /// - Parameters:
    ///   - download: The current `Downloading` instance
    ///   - state: The new `DownloadingState` the `Downloading` has transitioned to
    func download(_ download: GXDownloader, changedState state: GXDownloadingState)
    
    /// Triggered when a `Downloading` instance has fully completed its request.
    ///
    /// - Parameters:
    ///   - download: The current `Downloading` instance
    ///   - error: An optional `Error` if the download failed to complete. If there were no errors then this will be nil.
    func download(_ download: GXDownloading, completedWithError error: Error?)
    
    /// Triggered when a `Downloading` instance has fully completed its request.
    ///
    /// - Parameters:
    ///   - download: The current `Downloading` instance
    ///   - error: An optional `Error` if the download failed to complete. If there were no errors then this will be nil.
    func download(_ download: GXDownloading, startError error: GXDownloadingError?)
    
    /// Triggered periodically whenever the `Downloading` instance has more data. In addition, this method provides the current progress of the overall operation as a float.
    ///
    /// - Parameters:
    ///   - download: The current `Downloading` instance
    ///   - data: A `Data` instance representing the current binary data
    ///   - progress: A `Float` ranging from 0.0 - 1.0 representing the progress of the overall download operation.
    func download(_ download: GXDownloading, didReceiveData data: Data, progress: Float)
}
