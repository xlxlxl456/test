//
//  ARViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/24.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

final class ARViewController: UIViewController {
    
    @IBOutlet weak var markContainer:           UIView!
    @IBOutlet private weak var previewView:     CameraPreviewView!
    @IBOutlet private weak var resumeBtn:       UIButton!
    @IBOutlet private weak var newFacilityBtn:  UIButton!
    @IBOutlet private weak var accuracyLbl:     UILabel!
    @IBOutlet private weak var distanceLbl:     UILabel!
    
    private var tipDisplayed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ARManager.shared.delegate = self
        CameraManager.shared.previewView = previewView
        CameraManager.shared.statusDidChange = { [weak self] available in
            self?.updateResumeButton(isHidden: available)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAr()
        NotificationCenter.default.addObserver(self, selector: #selector(startAr), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAr), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAr()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let previewView = self?.previewView else {
                return
            }
            let deltaAngle = CGFloat(atan2f(Float(coordinator.targetTransform.b),
                                            Float(coordinator.targetTransform.a)))
            let transform = previewView.layer.affineTransform().rotated(by: -deltaAngle + 0.0001)
            previewView.layer.setAffineTransform(transform)
            
        }, completion: { [weak self] _ in
            self?.previewView.layer.setAffineTransform(.identity)
            self?.previewView.updateOrientation()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController,
            let vc = nc.topViewController as? NewFacilityViewController {
            vc.location = sender as? CLLocation
        }
    }
    
    @IBAction private func resumeCamera(_ sender: Any) {
        startCamera(completion: nil)
        updateResumeButton(isHidden: true)
    }
    
    @IBAction private func newFacility(_ sender: Any) {
//       xinglang 2020/11/20 新規する時スキップできるように start
//        UpdateLocationViewController.updateFacility(serialNumber: nil, viewController: self) { [weak self]
        UpdateLocationViewController.updateFacility(serialNumber: nil, viewController: self,withSkip: true) { [weak self]
//       xinglang 2020/11/20 新規する時スキップできるように end
            location in
            guard let self = self, let location = location else {
                return
            }
            self.performSegue(withIdentifier: "newFacility", sender: location)
        }
    }
}

extension ARViewController {
    @objc private func startAr() {
        guard checkExpiration() else {
            return
        }
        
        startCamera { [weak self] in
            ARManager.shared.authorizeLocation { authorized in
                if authorized {
                    self?.showReminder()
                    ARManager.shared.start()
                } else {
                    self?.showSetting("位置情報")
                }
            }
        }
        
        // 全体以外のときは新規ボタンは許可しない
        newFacilityBtn.isEnabled = Index.shared?.coverage == 0
        newFacilityBtn.alpha = newFacilityBtn.isEnabled ? 1 : 0.5
    }
    
    private func startCamera(completion: (() -> Void)?) {
        CameraManager.shared.startSession { [weak self] error in
            switch error {
            case .success:
                self?.updateResumeButton(isHidden: true)
                completion?()
                
            case .failure(.deviceError):
                self?.showAlert(title: "エラー", message: "カメラの起動に失敗しました。")
                
            case .failure(.notAuthorized):
                self?.showSetting("カメラ")
                
            case .failure(.unavailable):
                self?.showAlert(title: "エラー", message: "カメラの起動に失敗しました。")
                self?.updateResumeButton(isHidden: false)
            }
        }
    }
    
    @objc private func stopAr() {
        CameraManager.shared.stopSession()
        ARManager.shared.stop()
    }
    
    private func updateResumeButton(isHidden: Bool) {
        if resumeBtn.isHidden == isHidden {
            return
        }
        resumeBtn.isHidden = false
        resumeBtn.alpha = isHidden ? 1 : 0
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.resumeBtn.alpha = isHidden ? 0 : 1
        }) { [weak self] _ in
            self?.resumeBtn.isHidden = isHidden
        }
    }
    
    private func showReminder() {
        if tipDisplayed { return }
        tipDisplayed = true
        
//        xinglang 2020/11/25 Guest場合は別の提示する　start
//        showAlert(title:"確認", message: "デジカメとタブレットの時刻が合っている（補正値入力済みである）ことを確認してから、点検を開始して下さい。")
        
        if DataManager.guestMode{
            showAlert(title:"確認", message: "アクティベーションを完了しない場合は、保存したデータをPCソフトで読込が出来ません。")
        }else{
            showAlert(title:"確認", message: "デジカメとタブレットの時刻が合っている（補正値入力済みである）ことを確認してから、点検を開始して下さい。")
        }
//        xinglang 2020/11/25 Guest場合は別の提示する　end
    }
    
    private func checkExpiration() -> Bool {
//    xinglang    体験版でアクティベーションを無効にする start
        if DataManager.guestMode { return true }
//    xinglang    体験版でアクティベーションを無効にする end
        
         if let expiration = DataManager.expiration, expiration >= Date() {
            return true
        }
        showAlert(title: "確認", message: "有効期限が切れています。") {
            DataManager.deleteExpiration()
            (UIApplication.shared.delegate as? AppDelegate)?
                .transitionRootViewController(storyboardIdentifier: "ActivationViewController")
        }
        return false
    }
}

extension ARViewController: ARManagerDelegate {
    
    func didUpdate(accuracy: Double) {
        accuracyLbl.text = String(format: "AR (%.2fm)", accuracy)
        switch true {
        case 3... ~= accuracy:
            accuracyLbl.backgroundColor = UIColor.red.withAlphaComponent(0.75)
        case 1..<3 ~= accuracy:
            accuracyLbl.backgroundColor = UIColor.green.withAlphaComponent(0.75)
        case 0..<1 ~= accuracy:
            accuracyLbl.backgroundColor = UIColor.orange.withAlphaComponent(0.75)
        default:
            accuracyLbl.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            accuracyLbl.text = String(format: "AR", accuracy)
        }
    }
    
    func didUpdateLocation(facilities: [Index.Facility]) {
        if let distance = facilities.first?.distance {
            distanceLbl.isHidden = false
            if distance > 5 {
                distanceLbl.text = "点検対象まで約　\(Int(round(distance)))　mです。"
                distanceLbl.backgroundColor = UIColor.cyan.withAlphaComponent(0.75)
            } else {
                distanceLbl.text = "近くに点検対象があります。\nサムネイル画像を確認してください。"
                distanceLbl.backgroundColor = UIColor.orange.withAlphaComponent(0.75)
            }
        } else {
            distanceLbl.isHidden = true
        }
        
        let thumbnailVC = children.first(where: { $0 is ThumbnailViewController }) as? ThumbnailViewController
        thumbnailVC?.facilities = facilities
    }
}
