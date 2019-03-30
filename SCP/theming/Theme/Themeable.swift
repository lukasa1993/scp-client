//
//  Copyright © 2019 squarefrog. All rights reserved.
//

import UIKit

protocol Themeable {
    func apply(theme: Theme)
}

extension UITableViewCell: Themeable {
    func apply(theme: Theme) {
        textLabel?.textColor = theme.cellMainTextColor
        detailTextLabel?.textColor = theme.cellDetailTextColor

        for view in [self, textLabel, detailTextLabel] {
            view?.backgroundColor = theme.cellBackgroundColor
        }
    }
}
