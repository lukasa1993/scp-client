//
//  Copyright © 2019 squarefrog. All rights reserved.
//

import UIKit

struct LinearReveal {
    static func animate(duration: CFTimeInterval = 0.2,
                        timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut),
                        completion: ((Bool) -> Void)? = nil) {

        guard let rootView = UIApplication.shared.keyWindow?.rootViewController?.view else { return }

        // Snapshot the current view and add it to the root view
        let snapshotView = rootView.snapshotView(afterScreenUpdates: false)!
        rootView.addSubview(snapshotView)

        let mask = CAShapeLayer()
        mask.path = UIBezierPath(rect: snapshotView.bounds).cgPath
        snapshotView.layer.mask = mask

        var toPath = snapshotView.frame
        toPath.origin.y += snapshotView.frame.height

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = mask.path
        animation.toValue = UIBezierPath(rect: toPath).cgPath
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = AnimationDelegate { finished in
            snapshotView.removeFromSuperview()
            animation.delegate = nil
            completion?(finished)
        }

        mask.add(animation, forKey: nil)
    }
}
