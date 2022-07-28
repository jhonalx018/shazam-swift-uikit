//
//  UIView+Extensions.swift
//  Shazam
//
//  Created by Jhon Gomez on 7/25/22.
//

import Foundation
import UIKit

extension UIView {
    func addSubview(view: UIView, with constrains: [NSLayoutConstraint]) {
        self.addSubview(view)
        NSLayoutConstraint.activate(constrains)
    }
}
