//
//  Helpers.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import UIKit

extension Bool {
    /// 1 for true and 0 for false
    var intValue: Int { return self ? 1 : 0 }
}

extension String {
    /// - parameter givenCount: The number of objects, anything other than 1 results in a plural
    /// - returns: `self` if givenCount is 1, otherwised "`self`s"
    func pluralized(givenCount count: Int) -> String {
        return self + (count == 1 ? "" : "s")
    }
}

/// Designed to be used as a placeholder view in storyboards - background color is set to clear when loaded from nib
class PlaceholderView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
}
