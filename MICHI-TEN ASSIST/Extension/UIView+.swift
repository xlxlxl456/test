//
//  UIView+.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/13.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    func firstDescendant(where filter: @escaping (UIView) -> Bool) -> UIView? {
        if filter(self) { return self }
        for subView in subviews {
            if let target = subView.firstDescendant(where: filter) {
                return target
            }
        }
        return nil
    }
}
