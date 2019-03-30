//
//  Copyright © 2019 squarefrog. All rights reserved.
//

import UIKit

struct Theme {
    let accentColor: UIColor
    let backgroundColor: UIColor
    let navigationBarColor: UIColor
    let navigationTextColor: UIColor
    let cellBackgroundColor: UIColor
    let cellMainTextColor: UIColor
    let cellDetailTextColor: UIColor
    let cellSeparatorColor: UIColor
    let statusBarStyle: UIStatusBarStyle

    static var light: Theme {
        return Theme(accentColor: UIColor(red: 0.00, green: 0.45, blue: 1.00, alpha: 1.00),
                     backgroundColor: UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1.00),
                     navigationBarColor: UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.00),
                     navigationTextColor: UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00),
                     cellBackgroundColor: UIColor(white: 1, alpha: 1),
                     cellMainTextColor: UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.00),
                     cellDetailTextColor: UIColor(red: 0.53, green: 0.53, blue: 0.55, alpha: 1.00),
                     cellSeparatorColor: UIColor(red: 0.88, green: 0.88, blue: 0.90, alpha: 1.00),
                     statusBarStyle: .default)
    }

    static var dark: Theme {
        return Theme(accentColor: UIColor(red: 1.00, green: 0.51, blue: 0.00, alpha: 1.00),
                     backgroundColor: UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.00),
                     navigationBarColor: UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.00),
                     navigationTextColor: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00),
                     cellBackgroundColor: UIColor(red: 0.10, green: 0.10, blue: 0.11, alpha: 1.00),
                     cellMainTextColor: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00),
                     cellDetailTextColor: UIColor(red: 0.51, green: 0.51, blue: 0.53, alpha: 1.00),
                     cellSeparatorColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.00),
                     statusBarStyle: .lightContent)
    }
}
