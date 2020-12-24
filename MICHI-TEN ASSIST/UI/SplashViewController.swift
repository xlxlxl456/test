//
//  SplashViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/24.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


final class SplashViewController: UIViewController {
    
    @IBOutlet private weak var versionLbl: UILabel! {
        didSet {
            let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
            versionLbl.text = version.flatMap { "バージョン \($0)" }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.checkAuthorization()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthorization), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}


extension SplashViewController {
    @objc private func checkAuthorization() {
        CameraManager.checkAuthorization { [weak self] authorized in
            if authorized {
                self?.checkLocation()
            } else {
                self?.showSetting("カメラ")
            }
        }
    }
    
    private func checkLocation() {
        ARManager.shared.authorizeLocation { [weak self] authorized in
            if authorized {
                self?.checkData()
            } else {
                self?.showSetting("位置情報")
            }
        }
    }
    
    private func checkData() {
        if DataManager.dataExsits {
            if checkExpiration() {
                (UIApplication.shared.delegate as? AppDelegate)?
                    .transitionRootViewController(storyboardIdentifier: "ARViewController")
            }
            return
        }
        showAlert(title: "確認",
                  message: "TABdataフォルダが見つかりません。\nフォルダをコピーしてください。",
                  actionTitle: "リトライ",
                  action: { [weak self] in
                    self?.checkData()
        })
    }
    
    private func checkExpiration() -> Bool {
        if let expiration = DataManager.expiration {
            if expiration > Date() { return true }
            
            showAlert(title: "確認", message: "有効期限が切れています。") { [weak self] in
                DataManager.deleteExpiration()
                self?.performSegue(withIdentifier: "activation", sender: nil)
            }
            return false
        }
        performSegue(withIdentifier: "activation", sender: nil)
        return false
    }
}
