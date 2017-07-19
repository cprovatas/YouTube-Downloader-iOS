//
//  YTNotificationView.swift
//  YouTubeVideoDownloader
//
//  Created by Charlton Provatas on 1/7/17.
//  Copyright © 2017 Charlton Provatas. All rights reserved.
//

import Foundation
import UIKit

class YTNotificationView : UIView {
    
    private let label: UILabel! = {
        let l = UILabel()
        l.textAlignment = .center
        l.numberOfLines = 3
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        l.font = UIFont(name: "Avenir-Light", size: isIpad ? 25 : 18)
        return l
    }()
    
    convenience init(text: String) {
        self.init()
        self.frame = frame
        backgroundColor = .black
        alpha = 0
        let f = UIScreen.main.bounds
        layer.cornerRadius = 10
        frame.size = CGSize(width: f.size.width * 0.5, height: f.size.height * 0.2)
        frame.origin = CGPoint(x: f.size.width * 0.5 - frame.size.width * 0.5, y: f.size.height * 0.4 - frame.size.height * 0.5)
        label.text = text
        label.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        addSubview(label)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.95
        }) { (_) in
            self.perform(#selector(self.fadeOut), with: nil, afterDelay: 1)
        }
    }
    
    @objc private func fadeOut() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.frame.origin.y -= 15
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}
