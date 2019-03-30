//
//  Copyright © 2019 squarefrog. All rights reserved.
//

import UIKit

class AnimationDelegate: NSObject, CAAnimationDelegate {
    let completion: (Bool) -> Void

    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completion(flag)
    }
}
