//
//  SortButton.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/14.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

final class SortButton: UIButton {
    enum Sort {
        case ascending, descending
        
        var image: UIImage? {
            switch self {
            case .ascending:    return UIImage(systemName: "chevron.up")
            case .descending:   return UIImage(systemName: "chevron.down")
            }
        }
    }
    
    @IBInspectable var index: Int = 0
    
    var sort: Sort? {
        didSet {
            setImage(sort?.image, for: .normal)
            if sort != nil {
                previousSort = sort
            }
        }
    }
    
    private var previousSort: Sort?
    private var imageSize: CGSize { return CGSize(width: 16, height: 16) }
    
    func toggle() {
        switch sort {
        case .some(.ascending):     sort = .descending
        case .some(.descending):    sort = .ascending
        default:                    sort = previousSort ?? .ascending
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        imageView?.contentMode = .scaleAspectFit
    }
    
    override func imageRect(forContentRect contentRect:CGRect) -> CGRect {
        let origin = CGPoint(x: contentRect.width  - imageSize.width - imageEdgeInsets.right,
                             y: (contentRect.height - imageSize.height) / 2)
        return CGRect(origin: origin, size: imageSize)
    }
    
    override func titleRect(forContentRect contentRect:CGRect) -> CGRect {
        var frame = super.titleRect(forContentRect: contentRect)
        frame.origin.x = titleEdgeInsets.left
        return frame
    }
}

