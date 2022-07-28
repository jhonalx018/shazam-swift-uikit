//
//  UIImage+Extensions.swift
//  Shazam
//
//  Created by Jhon Gomez on 7/27/22.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
