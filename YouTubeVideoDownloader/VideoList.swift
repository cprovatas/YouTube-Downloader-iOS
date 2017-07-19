//
//  VideoList.swift
//  YouTubeVideoDownloader
//
//  Created by Charlton Provatas on 1/1/17.
//  Copyright © 2017 Charlton Provatas. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import AssetsLibrary
import MediaPlayer

class VideoList : UIViewController {
    
    fileprivate var videos: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action:#selector(mediaPlayerNextButtonAction))
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action:#selector(mediaPlayerPreviousButtonAction))
    }
    
    @IBOutlet weak var videoTable: UITableView! {
        didSet {
            videoTable.delegate = self
            videoTable.dataSource = self
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
            videoTable.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    @objc private func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if let indexPath = videoTable.indexPathForRow(at: gestureRecognizer.location(in: videoTable)) {
                if (videoTable.cellForRow(at: indexPath) as! VideoCell).progressBar.isHidden {
                    presentAlert(indexPath: indexPath)
                }
            }
        }
    }
    
    private func presentAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Save To Camera Roll", style: .default) { (_) in
            let path = Literals.rootDirectory.appendingPathComponent(self.videos[indexPath.row]).path
            if !UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) { return }
            
            ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: URL(fileURLWithPath: path), completionBlock: { (url, error) -> Void in
                if error == nil {
                    UIAlertView(title: "Saved To Camera Roll", message: nil, delegate: nil, cancelButtonTitle: "OK").show()
                }
            })
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.deleteVideo(indexPath)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: .none)        
        appendWithoutAddingDuplicates(videos: try! FileManager.default.contentsOfDirectory(atPath: Literals.rootDirectory.path))
        videoTable.reloadData()
        
        // set up handle control center events
        
    }
    
    @objc fileprivate func mediaPlayerNextButtonAction() {
        if let item = currentPlayer.currentItem {
              replaceVideo(nextVideo(fromFilename: (item.asset as! AVURLAsset).url.lastPathComponent))
        }
    }
    
    @objc fileprivate func mediaPlayerPreviousButtonAction() {
        if let item = currentPlayer.currentItem {
            replaceVideo(previousVideo(fromFilename: (item.asset as! AVURLAsset).url.lastPathComponent))
        }
    }
    
    fileprivate func appendWithoutAddingDuplicates(videos: [String]) {
        for video in videos {
            if !contains(video: video) {
                self.videos.append(video)
            }
        }
    }
    
    fileprivate func contains(video: String) -> Bool {
        for theVideo in self.videos {
            if video == theVideo {
                return true
            }
        }
        return video == ".DS_Store"
    }
    
    fileprivate var currentPlayer : AVPlayer!
}

extension VideoList : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath) as! VideoCell).progressBar.isHidden {
            initVideoPlayer(videos[indexPath.row])
        }else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func initVideoPlayer(_ name: String) {
        let videoPlayer = AVPlayerViewController()
        currentPlayer = AVPlayer(url: Literals.rootDirectory.appendingPathComponent(name))
        videoPlayer.player = currentPlayer
        
        present(videoPlayer, animated: true) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.player!.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.player!.currentItem)
            videoPlayer.player!.play()
            AVPlayerViewControllerManager.getForwardButton(videoPlayer).addTarget(self, action: #selector(self.mediaPlayerNextButtonAction), for: .touchUpInside)
            AVPlayerViewControllerManager.getBackButton(videoPlayer).addTarget(self, action: #selector(self.mediaPlayerPreviousButtonAction), for: .touchUpInside)
        }
    }
    
    @objc private func playerDidFinishPlaying(notification: NSNotification) {
        let url = ((notification.object as! AVPlayerItem).asset as! AVURLAsset).url.lastPathComponent
        replaceVideo(nextVideo(fromFilename: url))
    }
    
    fileprivate func replaceVideo(_ fileName: String) {
        currentPlayer.replaceCurrentItem(with: AVPlayerItem(url: Literals.rootDirectory.appendingPathComponent(fileName)))
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentPlayer!.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentPlayer!.currentItem)
        currentPlayer.play()
    }
    
    fileprivate func nextVideo(fromFilename file: String) -> String {
        let filtered = videos.filter({ FileManager.default.fileExists(atPath: Literals.rootDirectory.appendingPathComponent($0).path) })
        for var i in 0..<filtered.count {
            if filtered[i] == file {
                return i + 1 >= filtered.count ? filtered[0] : filtered[i + 1]
            }
        }
        return ""
    }
    
    fileprivate func previousVideo(fromFilename file: String) -> String {
        let filtered = videos.filter({ FileManager.default.fileExists(atPath: Literals.rootDirectory.appendingPathComponent($0).path) })
        for var i in 0..<filtered.count {
            if filtered[i] == file {
                return i - 1 < 0  ? filtered[filtered.count - 1] : filtered[i - 1]
            }
        }
        return ""
    }
    
}

extension VideoList : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Place Holder Foo"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let cell = (tableView.cellForRow(at: indexPath) as? VideoCell) {
            return cell.progressBar.isHidden
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteVideo(indexPath)
        }
    }
    
    fileprivate func deleteVideo(_ indexPath: IndexPath) {
        do {
            try FileManager.default.removeItem(at: Literals.rootDirectory.appendingPathComponent(videos[indexPath.row]))
            videos.remove(at: indexPath.row)
            videoTable.deleteRows(at: [indexPath], with: .left)
        }catch {
            UIAlertView(title: "Error", message: "Couldn't Delete File", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.red        
        let l = UILabel(frame: CGRect(x: view.center.x - 100, y: 3.5, width: 200, height: 20))
        l.textAlignment = .center
        l.text = "Your Downloads"
        l.font = UIFont(name: "Avenir", size: (isIpad ? 30 : 18))
        l.textColor = UIColor.white
        v.addSubview(l)
        return v
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
        let video = videos[indexPath.row]
        cell.titleLabel!.text = video.replacingOccurrences(of: ".mp4", with: "")
        if let image = UI.firstFrame(url: URL(fileURLWithPath: Literals.rootDirectory.appendingPathComponent(video).path)) {
            cell.videoImage.image = image
        }else if cell.imgUrl != nil {
            DispatchQueue.global(qos: .background).async {
                if let data = try? Data(contentsOf: cell.imgUrl!) {
                    DispatchQueue.main.async {
                        cell.videoImage.image = UIImage(data: data)
                    }
                }
            }
            
        }
        
        if FileManager.default.fileExists(atPath: Literals.rootDirectory.appendingPathComponent(video).path) {
            cell.downloadedState()
        }else {
            cell.downloadState()
        }
        
        return cell
    }
}

extension VideoList : YouTubeViewerDelegate {
    
    func downloadDidBegin(name: String, url: URL) {
        if index(forVideoName: name) == nil {
            appendWithoutAddingDuplicates(videos: [name])
            if videoTable == nil {
                setUp()
            }
            
            videoTable.reloadData()
            if let cell = videoTable.cellForRow(at: IndexPath(row: videos.count - 1, section: 0)) as? VideoCell {
                cell.imgUrl = url
                cell.downloadState()
            }
        }
    }
    
    func didReturnCurrentDownload(progress: Double, _ name: String) {
        if let index = index(forVideoName: name) {
            if let cell = videoTable.cellForRow(at: IndexPath(row: index, section: 0)) as? VideoCell {
                cell.progressBar.progress = Float(progress)
                cell.percentageLabel.text = "\(Int(Double(round(100 * progress) / 100) * 100))%"
                if progress == 1.0 {
                    cell.percentageLabel.text = "Done"
                    perform(#selector(fadeOut(cell:)), with: cell, afterDelay: 0.5)
                    cell.progressBar.isHidden = true
                }
            }
        }
    }
    
    @objc private func fadeOut(cell: VideoCell) {
        UIView.animate(withDuration: 0.4, animations: { 
            cell.percentageLabel.alpha = 0
        }) { (_) in
            cell.downloadedState()
        }
    }
    
    private func index(forVideoName name: String) -> Int? {
        
        for var i in 0..<videos.count {
            if videos[i] == name {
                return i
            }
        }
        return nil
    }
}

class VideoCell : UITableViewCell {
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videoImage: UIImageView!
    
    public var imgUrl : URL? 
    
    public func downloadState() {
        titleLabel!.alpha = 0.4
        percentageLabel.isHidden = false
        progressBar.isHidden = false
    }
    
    public func downloadedState() {
        percentageLabel.isHidden = true
        progressBar.isHidden = true
        titleLabel!.alpha = 1
    }
}
