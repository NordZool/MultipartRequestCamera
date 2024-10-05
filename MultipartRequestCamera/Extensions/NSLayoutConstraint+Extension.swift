//
//  NSLayoutConstraint+Extension.swift
//  MultipartRequestCamera
//
//  Created by nikita on 5.10.24.
//

import UIKit

extension NSLayoutConstraint {
    func priority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
