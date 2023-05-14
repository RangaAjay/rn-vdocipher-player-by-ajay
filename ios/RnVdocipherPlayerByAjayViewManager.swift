import Foundation
import SwiftUI

@objc (VideoPlayerViewManager)
class VideoPlayerViewManager: RCTViewManager {
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    override func view() -> UIView! {
        return VideoPlayerView()
    }
    
}


class VideoPlayerView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(ViewController().view)
    }
}
