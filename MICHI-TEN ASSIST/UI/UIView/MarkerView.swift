//
//  MarkerView.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/08/05.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

typealias MarkerInfo = (facility: Index.Facility, position: CGPoint)

class MarkerView: UIView {
    
    private static var markers = [String: MarkerView]()
    
    
    private let label =         UILabel()
    private let guideLayer =    CAShapeLayer()
    private var centerX:        NSLayoutConstraint?
    private var centerY:        NSLayoutConstraint?
    private var height:         NSLayoutConstraint?
    private var width:          NSLayoutConstraint?
    
    private var maxH: CGFloat        { superview?.bounds.height ?? 0 }
    private var minH: CGFloat        { 100 }
    private var aspectRatio: CGFloat    { 1 + sqrt(5) } //黄金比
    
    //一番近い対象しか表示しない仕様が、info数分を表示できる実装になってる
    static func update(_ info: [MarkerInfo], container: UIView) {
        //対象外になったマーカーを削除
        markers.keys.forEach { key in
            if !info.contains(where: {
                $0.facility.locationKey == key
            }) {
                markers.removeValue(forKey: key)?.removeFromSuperview()
            }
        }
        
        info.enumerated().forEach {
            if let key = $0.element.facility.locationKey {
                if markers[key] == nil {
                   markers[key] = addMarker(to: container)
                }
                markers[key]?.update($0.element, index: $0.offset)
            }
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            container.layoutIfNeeded()
        })
    }

    static func addMarker(to container: UIView) -> MarkerView {
        let size = container.bounds.height
        
        let marker = MarkerView()
        container.addSubview(marker)
        marker.borderWidth = 2
        marker.isHidden = true
        marker.translatesAutoresizingMaskIntoConstraints = false
        marker.frame = CGRect(x: 0, y: 0, width: size, height: size)
        
        marker.width = marker.widthAnchor.constraint(equalToConstant: 0)
        marker.height = marker.heightAnchor.constraint(equalToConstant: 0)
        marker.centerX = marker.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        marker.centerY = marker.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        marker.width?.isActive = true
        marker.height?.isActive = true
        marker.centerX?.isActive = true
        marker.centerY?.isActive = true
        
        marker.addSubview(marker.label)
        marker.label.font = .systemFont(ofSize: 32, weight: .medium)
        marker.label.translatesAutoresizingMaskIntoConstraints = false
        marker.label.frame = marker.frame
        marker.label.centerXAnchor.constraint(equalTo: marker.centerXAnchor).isActive = true
        marker.label.centerYAnchor.constraint(equalTo: marker.centerYAnchor).isActive = true
        
        marker.guideLayer.lineWidth = 2
        marker.guideLayer.lineDashPattern = [5, 5]
        
        return marker
    }
    
    static func remove() {
        markers.values.forEach {
            $0.removeFromSuperview()
        }
        markers.removeAll()
    }
    
    
    private func update(_ info: MarkerInfo, index: Int) {
        guard let arInfo = Setting.shared?.arInfo,
            let distance = info.facility.distance,
            let containerSize = superview?.bounds.size else {
            return
        }
        
        if let color = info.facility.markerColor, color != label.textColor {
            backgroundColor = color.withAlphaComponent(0.1)
            borderColor = color
            label.textColor = color
        }
        
        alpha = 1.0 - CGFloat(arInfo.alphaLevel) / 10
        
        label.text = "\(index + 1)"
        
        let size = max(minH, (maxH - (maxH - minH) / CGFloat(arInfo.showFilter) * CGFloat(distance)) * CGFloat(arInfo.markerSize))
        
        let w: CGFloat
        let h: CGFloat
        if Setting.shared?.arInfo.markerType == .cricle {
            w = 2 * size / aspectRatio
            h = w
            cornerRadius = w / 2
        } else {
            w = size / aspectRatio
            h = size
            cornerRadius = 0
        }
        
        height?.constant = h
        width?.constant = w
        
        centerX?.constant = containerSize.width * info.position.x
        centerY?.constant = containerSize.height * info.position.y
        
        if let guide = Setting.shared?.arInfo.guide, Bool(truncating: guide as NSNumber) {
            if guideLayer.superlayer == nil {
                layer.addSublayer(guideLayer)
            }
            guideLayer.strokeColor = borderColor?.cgColor
            
            let path = CGMutablePath()
            path.addLines(between: [CGPoint(x: 0, y: h / 2), CGPoint(x: w, y: h / 2)])
            path.addLines(between: [CGPoint(x: w / 2, y: 0), CGPoint(x: w / 2, y: h)])
            guideLayer.path = path
            
        } else {
            guideLayer.removeFromSuperlayer()
        }
        
        if isHidden {
            superview?.layoutIfNeeded() //初期表示時ははアニメショーンさせないように
            isHidden = false
        }
    }
}
