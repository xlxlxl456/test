//
//  MarginateLabel.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/14.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

final class MarginateLabel: UILabel {
    
    var edgeInsets = UIEdgeInsets.zero
    
    @IBInspectable var topInset: CGFloat {
        get { return edgeInsets.top }
        set { edgeInsets.top = newValue }
    }
    
    @IBInspectable var leftInset: CGFloat {
        get { return edgeInsets.left }
        set { edgeInsets.left = newValue }
    }
    
    @IBInspectable var bottomInset: CGFloat {
        get { return edgeInsets.bottom }
        set { edgeInsets.bottom = newValue }
    }
    
    @IBInspectable var rightInset: CGFloat {
        get { return edgeInsets.right }
        set { edgeInsets.right = newValue }
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height += edgeInsets.top + edgeInsets.bottom
        intrinsicContentSize.width += edgeInsets.left + edgeInsets.right
        return intrinsicContentSize
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInsets))
    }
}
