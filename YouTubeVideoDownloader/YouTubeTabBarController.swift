//
//  TabBarController.swift
//  YouTubeVideoDownloader
//
//  Created by Charlton Provatas on 1/2/17.
//  Copyright © 2017 Charlton Provatas. All rights reserved.
//

import Foundation
import UIKit

class YouTubeTabBarController : UITabBarController {
    
    override func loadView() {
        super.loadView()
        setUpChildViewControllers()
    }
    
    private func setUpChildViewControllers() {
        if viewControllers != nil && viewControllers!.count > 1 && viewControllers![0] is YouTubeViewer && viewControllers![1] is VideoList {            
            (viewControllers![0] as! YouTubeViewer).delegate = viewControllers![1] as! VideoList
        }
    }
    
}
