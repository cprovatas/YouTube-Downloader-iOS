//
//  WKTrafficManager.swift
//  YouTubeVideoDownloader
//
//  Created by Charlton Provatas on 1/14/17.
//  Copyright © 2017 Charlton Provatas. All rights reserved.
//

import Foundation

final class WKTrafficManager : URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        
        if request.url!.absoluteString.contains("https://m.youtube.com/watch?") {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shouldShowDownloadButton"), object: nil)
        }else if request.url!.absoluteString.contains("https://m.youtube.com/feed?") {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shouldHideDownloadButton"), object: nil)
        }        
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {}
        
    override func stopLoading() {}
}
