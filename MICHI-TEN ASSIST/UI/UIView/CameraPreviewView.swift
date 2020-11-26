//
//  CameraPreviewView.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/25.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraPreviewView: UIView {
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return layer as? AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return previewLayer?.session }
        set { previewLayer?.session = newValue }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    func initiateOrientation() {
        let windowOrientation = window?.windowScene?.interfaceOrientation ?? .unknown
        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: windowOrientation) {
            previewLayer?.connection?.videoOrientation = videoOrientation
        }
    }
    
    func updateOrientation() {
        if let videoOrientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation) {
            previewLayer?.connection?.videoOrientation = videoOrientation
        }
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}
