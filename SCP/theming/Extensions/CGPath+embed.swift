//
//  Copyright © 2019 squarefrog. All rights reserved.
//

import CoreGraphics

extension CGPath {
    func embed(in boundingRect: CGRect) -> CGPath {
        let path = CGMutablePath()

        path.addRect(boundingRect)
        path.addPath(self)

        return path
    }
}
