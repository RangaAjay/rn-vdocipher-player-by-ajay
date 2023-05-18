//
//  File.swift
//  rn-vdocipher-player-by-ajay
//
//  Created by Ajay on 14/05/23.
//

import Foundation
import UIKit
import VdoFramework
import AVFoundation
import AVKit

class ViewController: UIViewController, AssetPlaybackDelegate {

    @IBOutlet weak var downloadStateLabel: UILabel!
    @IBOutlet weak var downloadActionButton: UIButton!
    @IBOutlet weak var playOnlineButton: UIButton!
    @IBOutlet weak var playOfflineButton: UIButton!
    @IBOutlet weak var container: UIView!
    
    fileprivate var playerViewController = AVPlayerViewController()
    
    private var asset: VdoAsset?
    
    private var otp = "20160313versIND313dgKrFOzMsDcQQxb85m3eMUGhATPIqHcGbBkVOmWsaX6jF1"
    private var playbackInfo = "eyJ2aWRlb0lkIjoiMGViNTVkNWRjMjI2NGY4MGIxOWMwYzI0YmZmYWJmZTMifQ=="
    private var videoId = "0eb55d5dc2264f80b19c0c24bffabfe3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting the AVPlayer controller in a subview
        self.playerViewController.view.frame = self.container.bounds
        self.playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addChild(self.playerViewController)
        self.container.addSubview(self.playerViewController.view)
        self.playerViewController.didMove(toParent: self)
        
        // listen to the download events
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress(_:)), name: .AssetDownloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadStateChange(_:)), name: .AssetDownloadStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadFailed(_:)), name: .AssetDownloadFailed, object: nil)
        
        // create a delegate for tracking player state
        VdoCipher.setPlaybackDelegate(delegate: self)
        
        // create a new asset
        VdoAsset.createAsset(videoId: videoId) { asset, error in
            if let error = error
            {
                // Remove buffering icon and show error
                print("Error loading video \(error)")
            }
            else
            {
                self.asset = asset // keep this asset reference for your use
                DispatchQueue.main.async {
                    // enable the UI for playing. remove buffering icon if showing
                    self.playOnlineButton.isEnabled = true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadStateLabel.text = "Generating asset..."
        playOfflineButton.isEnabled = false
    }
    
    private func updateUI(downloadState: VdoAsset.DownloadState?, percentDownload: Double = -1) {
        self.playOfflineButton.isEnabled = false
        switch downloadState {
        case .notDownloaded:
            self.downloadStateLabel.text = "not downloaded"
            self.downloadActionButton.setTitle("Download", for: .normal)
            break;
        case .downloaded:
            self.downloadStateLabel.text = "downloaded"
            self.downloadActionButton.setTitle("Delete", for: .normal)
            self.playOfflineButton.isEnabled = true
            break;
        case .downloading:
            self.downloadStateLabel.text = "downloading \(percentDownload)"
            self.downloadActionButton.setTitle("Cancel", for: .normal)
            break;
        case .paused:
            self.downloadStateLabel.text = "paused \(percentDownload)"
            self.downloadActionButton.setTitle("Cancel", for: .normal)
            break;
        default:
            self.downloadStateLabel.text = "getting download state..."
        }
    }
    
    // MARK: Notification handlers
    
    @objc func handleDownloadStateChange(_ notification: Notification) {
        print("handle download state change")
        let notice = notification.userInfo!
        guard videoId == notice[VdoAsset.Keys.videoId] as? String else {
            return
        }
        guard let stateRawValue = notice[VdoAsset.Keys.downloadState] as? String,
              let newState = VdoAsset.DownloadState(rawValue: (stateRawValue)) else {
            return
        }
        print("state change: \(newState)")
        DispatchQueue.main.async {
            self.updateUI(downloadState: newState)
        }
    }
    
    @objc func handleDownloadProgress(_ notification: Notification) {
        print("handle download progress")
        let notice = notification.userInfo!
        guard videoId == notice[VdoAsset.Keys.videoId] as? String else {
            return
        }
        guard let percent = notice[VdoAsset.Keys.percentDownloaded] as? Double else {
            return
        }
        print("progress percent: \(percent)")
        DispatchQueue.main.async {
            self.updateUI(downloadState: .downloading, percentDownload: percent)
        }
    }
    
    @objc func handleDownloadFailed(_ notification: Notification) {
        print("handle download failed")
        let notice = notification.userInfo!
        guard let message = notice[VdoAsset.Keys.message] as? String, let code = notice[VdoAsset.Keys.code] else {return}
        print("Download Failed with message:\(message) code:\(code)")
        DispatchQueue.main.async {
            self.updateUI(downloadState: .notDownloaded)
        }
    }

    @IBAction func playOnline(_ sender: Any) {
        guard let asset = asset else {
            return print("not ready for playback")
        }
        asset.playOnline(otp: otp, playbackInfo: playbackInfo)
    }

    @IBAction func playOffline(_ sender: Any) {
        guard let asset = asset else {
            return print("not ready for offline playback")
        }
        if asset.downloadState != .downloaded {
            return print("not downloaded yet")
        }
        asset.playOffline()
    }

    @IBAction func downloadAction(_ sender: Any) {
        guard let asset = asset, let button = sender as? UIButton, let buttonText = button.currentTitle else {
            return print("not ready for playback or action not defined")
        }
        print("title is \(String(describing: button.currentTitle))")
        print("download action \(buttonText)")
        switch buttonText {
        case "Delete":
            print("downloaded, now can delete")
            asset.deleteDownload()
        case "Cancel":
            print("downloading..., now can cancel")
            asset.cancelDownload()
        case "Download":
            print("download action triggered")
            asset.startDownload(otp: otp, playbackInfo: playbackInfo)
        default:
            print("can't get here")
        }
        
    }
}

extension ViewController {
    func streamPlaybackManager(playerReadyToPlay player: AVPlayer) {
        // player is ready to play
        player.play()
    }
    
    func streamPlaybackManager(playerCurrentItemDidChange player: AVPlayer) {
        // player current item has changed
        playerViewController.player = player
    }
    
    func streamLoadError(error: VdoError) {
        // Error occured while initiating playback
        print("Unable to play video. Due to error \n\n \(error)")
    }
    
    func getAllDownloadedVideos() -> [VdoFramework.DownloadInfo]{
        let allDownloads = VdoCipher.getListOfDownloads()
        return allDownloads
    }
    
    func getVideosDownloadStatus(_ arrVideosIds : [String])  -> [VdoFramework.DownloadInfo]{
        let downloads = VdoCipher.getListOfDownloads(filterBy: DownloadInfoFilter.init(videoId: arrVideosIds, downloadState: [ .downloaded]))
        return downloads;
    }
}
