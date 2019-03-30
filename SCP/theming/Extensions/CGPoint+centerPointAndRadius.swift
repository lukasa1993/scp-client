//
//  Copyright © 2019 squarefrog. All rights reserved.
//

import CoreGraphics

/// Create a rect that will encompass a circle given a center point and radius
extension CGRect {
    init(centerPoint: CGPoint, radius: CGFloat) {
        self = CGRect(origin: centerPoint, size: CGSize.zero).insetBy(dx: -radius, dy: -radius)
    }
}
