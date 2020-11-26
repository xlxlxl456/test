//
//  CameraManager.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/11.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

final class CameraManager {
    
    enum StartSessionResult {
        case success, failure(Failure)
        
        enum Failure {
            case notAuthorized, deviceError, unavailable
        }
    }
    
    static var shared = CameraManager()
    
    weak var previewView: CameraPreviewView? {
        didSet { previewView?.session = session }
    }
    
    var statusDidChange: ((Bool) -> Void)?
    
    var fieldOfView: Float? {
        //カメラの画角
        return device?.activeFormat.videoFieldOfView
    }
    
    private let device =
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) ??
        AVCaptureDevice.default(for: .video)
    
    private let session =       AVCaptureSession()
    private let sessionQueue =  DispatchQueue(label: "CameraManager.sessionQueue")
    private var input:          AVCaptureDeviceInput?
    private let output =        AVCapturePhotoOutput()
    
    private var configCompleted: Bool {
        return input != nil
    }
    
    private var isSessionAvailable: Bool {
        return session.isRunning && !session.isInterrupted
    }
    
    func startSession(completion: @escaping (StartSessionResult) -> Void) {
        CameraManager.checkAuthorization { [weak self] authorized in
            if !authorized {
                completion(.failure(.notAuthorized))
                return
            }
            
            self?.config(completion: { success in
                if !success {
                    completion(.failure(.deviceError))
                    return
                }
                
                self?.sessionQueue.async {
                    if self?.isSessionAvailable != true {
                        self?.session.startRunning()
                    }

                    if self?.isSessionAvailable == true {
                        self?.addObservers()
                        DispatchQueue.main.async { completion(.success) }
                    } else {
                        // startRunningに時間がかかる場合がある
                        self?.sessionQueue.asyncAfter(deadline: .now() + 0.5) {
                            if self?.isSessionAvailable == true {
                                self?.addObservers()
                                DispatchQueue.main.async { completion(.success) }
                            } else {
                                DispatchQueue.main.async { completion(.failure(.unavailable)) }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            self?.removeObservers()
        }
    }
}
 
extension CameraManager {
    
    private func config(completion: @escaping (Bool) -> Void) {
        if configCompleted {
            completion(true)
            return
        }
        
        sessionQueue.async { [weak self] in
            self?.configAsync(completion: completion)
        }
    }
    
    private func configAsync(completion: @escaping (Bool) -> Void) {
        defer {
            session.commitConfiguration()
            DispatchQueue.main.async { [weak self] in
                if let result = self?.configCompleted {
                    completion(result)
                }
            }
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard let device = device,
            let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        guard session.canAddInput(input) else {
            return
        }
        session.addInput(input)
        
        guard session.canAddOutput(output) else {
            return
        }
        session.addOutput(output)
        
        DispatchQueue.main.async { [weak self] in
            self?.previewView?.initiateOrientation()
        }
        self.input = input
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionStatusDidChange), name: .AVCaptureSessionRuntimeError, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionStatusDidChange), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionStatusDidChange), name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func sessionStatusDidChange() {
        sessionQueue.async { [weak self] in
            guard let isSessionAvailable = self?.isSessionAvailable else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.statusDidChange?(isSessionAvailable)
            }
        }
    }
}

extension CameraManager {
    
    static func checkAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in
                DispatchQueue.main.async() {
                    self.checkAuthorization(completion:completion)
                }
            }
        case .restricted, .denied:
            completion(false)
        case .authorized:
            completion(true)
        default:
            break
        }
    }
}

