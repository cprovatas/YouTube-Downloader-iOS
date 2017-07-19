//
//  Extensions.swift
//  YouTubeVideoDownloader
//
//  Created by Charlton Provatas on 1/2/17.
//  Copyright © 2017 Charlton Provatas. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import UIKit

public let isIpad = UI_USER_INTERFACE_IDIOM() == .pad
public let isPhone = UI_USER_INTERFACE_IDIOM() == .phone

extension UIViewController {
    func setUp() {
        loadView()
        viewDidLoad()
        viewWillAppear(false)
        viewDidAppear(false)
        viewDidLayoutSubviews()
    }
}

extension UITabBarItem {
    func set(color: UIColor) {
        if var newImage = image?.withRenderingMode(.alwaysTemplate) {
            UIGraphicsBeginImageContextWithOptions(newImage.size, false, newImage.scale)
            color.set()
            newImage.draw(in: CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            image = newImage
        }
    }
}

class UI {
    public class func addShadow(_ view: UIView) {
        
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    public class func firstFrame(url: URL) -> UIImage? {
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        generator.appliesPreferredTrackTransform = true
        if let image = try? UIImage(cgImage: generator.copyCGImage(at: CMTime(seconds: 30, preferredTimescale: 1), actualTime: nil)) {
            return image
        }
        return nil
    }    
}
