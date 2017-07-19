//
//  AVPlayerViewControllerManager.swift
//  YouTubeVideoDownloader
//
//  Created by Charlton Provatas on 1/2/17.
//  Copyright © 2017 Charlton Provatas. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class AVPlayerViewControllerManager : NSObject {
        
    public func blockAvPlayer() {
        UIApplication.shared.windows[0].makeKeyAndVisible()        
        perform(#selector(searchForAndDismissFullScreen), with: nil, afterDelay: 0.6)
    }
    
    public class func getBackButton(_ playerViewController: AVPlayerViewController) -> UIButton {
        if let button = playerViewController.view.getBackButton() {
            return button
        }
        return UIButton()
    }
    
    public class func getForwardButton(_ playerViewController: AVPlayerViewController) -> UIButton {
        if let button = playerViewController.view.getForwardButton() {
            return button
        }
        return UIButton()
    }
    
    @objc private func searchForAndDismissFullScreen() {
        if UIApplication.shared.windows.count < 2 { return }        
        for subview in UIApplication.shared.windows[1].subviews {
            subview.searchForAndTapFullScreen()
        }
    }
}


fileprivate extension UIView {
    func searchForAndTapFullScreen() {
        for subview in subviews {
            if String(describing: subview).contains("AVButton") {
                (subview as! UIButton).sendActions(for: .touchUpInside)
            }
            subview.searchForAndTapFullScreen()
        }
    }
    
    func getBackButton() -> UIButton? {
        for subview in subviews {
            if String(describing: subview).contains("AVForceButton") {
                return subview as? UIButton
            }
            if let button = subview.getBackButton() {
                return button
            }
        }
        return nil
    }
    
    func getForwardButton() -> UIButton? {
        for subview in subviews {
            if String(describing: subview).contains("AVForceButton") && subview.frame.origin.x > UIScreen.main.bounds.size.width * 0.5 {
                return subview as? UIButton
            }
            if let button = subview.getForwardButton() {
                return button
            }
            
        }
        return nil
    }
}
