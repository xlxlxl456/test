//
//  UpdateLocationViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/08/08.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import CoreLocation

final class UpdateLocationViewController: UIAlertController {
    
    private let locationManager = CLLocationManager()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private var locations = [CLLocation]()
    private var completion: ((CLLocation?) -> Void)?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateLocation() {
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: UIApplication.didEnterBackgroundNotification, object: nil)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
        if let messageLbl = view.firstDescendant(where: {
            ($0 as? UILabel)?.text?.hasSuffix("\n\n\n") == true
        }), let container = messageLbl.superview {
            container.addSubview(progressView)
            progressView.frame.size.width = container.frame.width - 32
            progressView.center = messageLbl.center
            progressView.frame.origin.y += 16
        }
    }
    
    @objc func close() {
        locationManager.stopUpdatingLocation()
        completion?(nil)
        dismiss(animated: true)
    }
}

extension UpdateLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        self.locations.append(location)
        
        let count = self.locations.count
        let progress = 100 * count / (Setting.shared?.arInfo.sma ?? 10)
        message = "\n\(progress)%\n\n\n"
        progressView.progress = Float(progress) / 100
        
        if progress == 100 {
            locationManager.stopUpdatingLocation()
            
            let sum = self.locations.reduce(into: CLLocationCoordinate2D()) { (sum, location) in
                sum.latitude += location.coordinate.latitude
                sum.longitude += location.coordinate.longitude
            }
            let averaged = CLLocation(latitude: sum.latitude / Double(count), longitude: sum.longitude / Double(count))
            
            self.dismiss(animated: true) { [weak self] in
                self?.completion?(averaged)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        completion?(nil)
        weak var presenting = presentingViewController
        self.dismiss(animated: true) {
            presenting?.showAlert(title: "エラー", message: "現在地の取得に失敗しました。")
        }
    }
}

extension UpdateLocationViewController {
//   xinglang 2020//11/20 withSkipを追加して、新規する時alertにskipがある start
    static func updateFacility(serialNumber: String?, viewController: UIViewController, showConfirm: Bool = false,withSkip: Bool = false, completion: ((CLLocation?) -> Void)? = nil)
//    static func updateFacility(serialNumber: String?, viewController: UIViewController, showConfirm: Bool = false, completion: ((CLLocation?) -> Void)? = nil)
//   xinglang 2020//11/20 withSkipを追加して、新規する時alertにskipがある start
    {
        self.show(from: viewController,withSkip: withSkip) { [weak viewController] location in
            guard let location = location else {
                completion?(nil)
                return
            }
            
            guard showConfirm, let sn = serialNumber else {
                if let serialNumber = serialNumber {
                    DataManager.update(serialNumber: serialNumber, location: location)
                }
                completion?(location)
                return
            }
            
            let facility = Index.shared?.facilities?.first(where: {
                $0.facility?.serialNumber == sn
            })?.facility
            
            let message = "管理番号\t\(sn)\n\n" +
                "現在の緯度\t\(facility?.latitudeStr ?? "")\n" +
                "現在の経度\t\(facility?.longitudeStr ?? "")\n\n" +
                "更新する緯度\t\(location.coordinate.latitude)\n" +
                "更新する経度\t\(location.coordinate.longitude)"
            
            viewController?.showAlert(title: "確認",
                                      message: message,
                                      cancelButton: true,
                                      actionTitle: "位置更新",
                                      action: {
                                        DataManager.update(serialNumber: sn, location: location)
                                        completion?(location)
            })
        }
    }
    
    private static func show(from viewController: UIViewController,withSkip: Bool, completion: @escaping (CLLocation?) -> Void) {
        let alert = UpdateLocationViewController(title: "GPSの補正を行っています。\nアンテナの位置を変えないでください。",
                                            message: "\n0%\n\n\n",
                                            preferredStyle: .alert)
        alert.completion = completion
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: { [weak alert] _ in
            alert?.locationManager.stopUpdatingLocation()
            alert?.completion?(nil)
        }))
        
//            xinglang 2020/11/27 GPSが取得していない時スキップはクリックできない　start
        if withSkip {
            let action = UIAlertAction(title: "スキップ", style: .default, handler: { [weak alert] _ in
                alert?.locationManager.stopUpdatingLocation()
                let location = alert?.locations.last
                alert?.completion?(location)
            })
            alert.addAction(action)
            action.isEnabled = false
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (Timer) in
                    if alert.locations.first != nil{
                        action.isEnabled = true
                        Timer.invalidate()
                    }
                }
            }
        }
//            xinglang 2020/11/27 GPSが取得していない時スキップはクリックできない　end
        
        viewController.present(alert, animated: true) { [weak alert]  in
            alert?.updateLocation()
        }
    }
}
