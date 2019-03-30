//
//  Copyright © 2019 squarefrog. All rights reserved.
//

import UIKit

struct CircularReveal {
    static func animate(from centerPoint: CGPoint,
                        duration: CFTimeInterval = 0.8,
                        timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut),
                        completion: ((Bool) -> Void)? = nil) {

        guard let rootView = UIApplication.shared.keyWindow?.rootViewController?.view else { return }

        // Snapshot the current view and add it to the root view
        let snapshotView = rootView.snapshotView(afterScreenUpdates: false)!
        rootView.addSubview(snapshotView)

        // Calculate the distance between the senders center point and the screens origin
        let hypotenuse = hypot(centerPoint.x, centerPoint.y)

        // Embed circular paths inside a rect
        // When used in combination with .evenOdd fill rule this effectively inverts the mask
        var startPath = CGPath(ellipseIn: CGRect(centerPoint: centerPoint, radius: 0), transform: nil)
        startPath = startPath.embed(in: snapshotView.bounds)

        var endPath = CGPath(ellipseIn: CGRect(centerPoint: centerPoint, radius: hypotenuse), transform: nil)
        endPath = endPath.embed(in: snapshotView.bounds)

        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        mask.path = startPath
        snapshotView.layer.mask = mask

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startPath
        animation.toValue = endPath
        animation.duration = duration
        animation.timingFunction = timingFunction
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
