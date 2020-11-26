//
//  ActiveManager.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/29.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreMotion

protocol ARManagerDelegate: NSObject {
    var markContainer: UIView! { get }
    func didUpdate(accuracy: Double)
    func didUpdateLocation(facilities:[Index.Facility])
}

final class ARManager: NSObject {
    
    enum Info {
        case ar, location(distans: Int, accuracy: Float)
    }
    
    static var shared = ARManager()
    
    weak var delegate: ARManagerDelegate?
    
    private let locationManager = CLLocationManager()
    private var locationAuthorization: ((Bool) -> Void)?
    private var locations = [CLLocation]()
    private var location: CLLocation?
    private var heading: CLHeading?
    
    private let motionManager = CMMotionManager()
    private let motionQueue =  OperationQueue()
    private var motion: CMDeviceMotion?
    
    func authorizeLocation(completion: ((Bool) -> Void)?) {
        locationAuthorization = nil
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationAuthorization = completion
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion?(false)
        case .authorizedAlways, .authorizedWhenInUse:
            completion?(true)
        default:
            break
        }
    }
    
    func start() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.3
            motionManager.startDeviceMotionUpdates(to: motionQueue) { [weak self] (montion, error) in
                // 端末の向きが更新される度にマーカーを更新
                DispatchQueue.main.async {
                    if let self = self, let montion = montion, error == nil {
                        self.motion = montion
                        self.updateAR()
                    }
                }
            }
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        location = nil
        locations.removeAll()
        heading = nil
        
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
        
        delegate?.didUpdate(accuracy: -1)
        delegate?.didUpdateLocation(facilities: [])
        MarkerView.remove()
        GPSLog.save()
    }

    func updateAR() {
        guard let arInfo = Setting.shared?.arInfo else {
            delegate?.didUpdateLocation(facilities: [])
            return
        }
        
        var angles = [String: Double]()
        
        let facilities = Array(
            (Index.shared?.facilities ?? []).filter { facility in
                //マーカー表示可能距離で絞る
                guard let distance = facility.distance,
                    distance <= Double(arInfo.showFilter) else {
                    return false
                }
                //表示範囲角度で絞る
                if let location = facility.location, let angle = angle(to: location),
                    Double(-arInfo.maskL)...Double(arInfo.maskR) ~= angle {
                    if let key = facility.locationKey {
                        angles[key] = angle
                    }
                    return true
                }
                return false
            }.prefix(3)
        ).sorted(by: { $0.distance ?? 0 < $1.distance ?? 0 })

        //マーカー以外の画面要素を更新
        delegate?.didUpdateLocation(facilities: facilities)
        
        //マーカーを更新
        guard Setting.shared?.arInfo.markerType != Setting.ARInfo.MarkerType.none,
            let verticalPosition = verticalPosition,
            let container = delegate?.markContainer,
            let facility = facilities.first,
            let key = facility.locationKey,
            let angle = angles[key],
            let horizontalPosition = horizontalPosition(for: angle) else {
                MarkerView.remove()
                return
        }
        
        let info = (facility, CGPoint(x: horizontalPosition, y: verticalPosition))
        MarkerView.update([info], container: container)
    }
}

extension ARManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizeLocation(completion: locationAuthorization)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        upcateLocation(location)
        
        // 各施設までの距離を更新しておく
        Index.shared?.facilities?.enumerated().forEach {
            Index.shared?.facilities?[$0.offset].distance = $0.element.location?.distance(from: self.location ?? location)
        }
        
        delegate?.didUpdate(accuracy: location.horizontalAccuracy)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.start()
        }
    }
}

extension ARManager {
    //端末の向き、現在地より、目標地との角度を算出（0：真っ正面　正数：右　負数；左）
    private func angle(to destination: CLLocation) -> Double? {
        guard let location = location,
            var heading = heading?.trueHeading else {
            return nil
        }
        
        //現在地から目標地までの距離（斜辺）
        let distance = destination.distance(from: location)
        if distance == 0 {
            return nil
        }

        //現在地と同じ経度、目標地と同じ緯度の点（三角の直角）
        let rightAngle = CLLocation(latitude: destination.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
        //直角から目標地までの距離（現在地の対辺）
        let latitudeDistance = destination.distance(from: rightAngle)
        //真北から、目標地までの角度（現在地鋭角の角度）
        var angle = asin(latitudeDistance / distance) * 180 / .pi

        switch true {
        case destination.coordinate.latitude < location.coordinate.latitude &&
            destination.coordinate.longitude >= location.coordinate.longitude:
            //目標地が現在地の南西
            angle = abs(90 - angle) + 90
        case destination.coordinate.latitude <= location.coordinate.latitude &&
             destination.coordinate.longitude < location.coordinate.longitude:
            //目標地が現在地の南西
            angle += 180
            
        case destination.coordinate.latitude > location.coordinate.latitude &&
             destination.coordinate.longitude < location.coordinate.longitude:
            //目標地が現在地の北西
            angle = abs(90 - angle) + 270
        default:
            //目標地が現在地の北東
            break
        }
        
        //端末の上部が向いている方向を、横向き時端末の背面が向いている方向に変換
        switch orientation {
        case .landscapeLeft:    heading = heading < 90 ? heading + 270 : heading - 90
        case .landscapeRight:   heading = heading >= 270 ? heading - 270 : heading + 90
        default: break
        }
        //端末の向きを加味
        var degree = angle - heading
        if degree > 180 { degree -= 360 }
        return degree
    }
    
    //目標地との角度より、画面表示の水平座標を算出（0：真っ正面　0.5：画面右端　-0.5；画面左端）
    private func horizontalPosition(for angle: Double) -> Double? {
        //カメラの水平画角
        guard let fieldOfView = CameraManager.shared.fieldOfView.map({ Double($0 / 2) }) else {
            return nil
        }
        return sin(angle * .pi / 180) / sin(fieldOfView * .pi / 180) / 2
    }
    
    //端末の向きより、画面表示の垂直座標を算出（0：真っ正面　0.5：画面上端　-0.5；画面下端）
    private var verticalPosition: Double? {
        guard var roll = motion?.attitude.roll else {
            return nil
        }
        
        if orientation == .landscapeRight {
            roll = -roll
        }
        
        //カメラの垂直画角は取れないが、44°とする（通常水平画角より狭い）
        let angleOfView = 22.0
        
        if -.pi..<(-0.5 * .pi) ~= roll {
            return sin(1.5 * .pi + roll) / sin(angleOfView * .pi / 180) / 2
        } else {
            return sin(-0.5 * .pi + roll) / sin(angleOfView * .pi / 180) / 2
        }
    }
    
    private var orientation: UIInterfaceOrientation {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    //sma設定によって現在地座標を平均化する
    private func upcateLocation(_ new: CLLocation) {
        let sma = Setting.shared?.arInfo.sma ?? Int(Setting.ARInfo.InputLimit.sma.range.upperBound)
        locations.append(new)
        if locations.count > sma {
            locations = Array(locations.suffix(sma))
        }
        
        let count = Double(locations.count)
        
        let sum = locations.reduce(into: CLLocationCoordinate2D()) { (sum, location) in
            sum.latitude += location.coordinate.latitude
            sum.longitude += location.coordinate.longitude
        }
        let averaged = CLLocation(latitude: sum.latitude / count, longitude: sum.longitude / count)
        location = averaged
        GPSLog.add(new, sum: sum, average: averaged.coordinate)
    }
}
