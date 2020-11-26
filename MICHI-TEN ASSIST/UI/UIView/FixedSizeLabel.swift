//
//  FixedSizeLabel.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/09/15.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

final class FixedSizeLabel: UILabel {

    @IBInspectable var placeholder: String?
    
    override public var intrinsicContentSize: CGSize {
        guard let placeholder = placeholder else {
            return super.intrinsicContentSize
        }
        
        let dummy = UILabel(frame: frame)
        dummy.font = font
        dummy.text = placeholder
        return dummy.intrinsicContentSize
    }
}
