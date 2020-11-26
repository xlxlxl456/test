//
//  AppDelegate.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/14.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DataManager.setup()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        DeviceLog.save()
        GPSLog.save()
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        DeviceLog.save()
        GPSLog.save()
        DataManager.delinkImages()
    }
    
    func transitionRootViewController(storyboardIdentifier: String) {
        guard let window = window else {
            return
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardIdentifier)
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}

