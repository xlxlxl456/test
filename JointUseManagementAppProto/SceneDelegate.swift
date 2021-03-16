//
//  SceneDelegate.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2019/12/14.
//  Copyright © 2019 FURUKAWA ELECTRIC CO., LTD. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        //guard let _ = (scene as? UIWindowScene) else { return }
        
        // JSONファイルが存在するかどうかを確認
        // フォルダが存在するかで判定
        let dirURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let contentUrls = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)
            dirs = contentUrls.map{$0.lastPathComponent}
        } catch {
            print("error: failed get document directory info")
        }
        
        var cExit: Bool = false
        var tExit: Bool = false
        if 0 < dirs.count {
            for d in dirs {
                print("dirName: \(d)")
                let bURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let cFile = "\(d)/DeviceData/Completion.json"
                let cURL = bURL.appendingPathComponent(cFile)
                let isDeviceDataExist: Bool = FileManager.default.fileExists(atPath: cURL.path)
                if isDeviceDataExist == true {
                    cExit = true
                }
                
                let tFile = "\(d)/DeviceData/TimeStamp.json"
                let tURL = bURL.appendingPathComponent(tFile)
                let isTimeStampExist: Bool = FileManager.default.fileExists(atPath: tURL.path)
                if isTimeStampExist == true {
                    tExit = true
                }
            }
        }
        else {
            print("not exist dir")
            createInitFile()
        }
        
        // past code
//        let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileName = "DeviceData/Completion.json"
//        let fileURL = dir.appendingPathComponent(fileName)
        
//        let isDeviceDataExist: Bool = FileManager.default.fileExists(atPath: fileURL.path)
//        if isDeviceDataExist == false {
//            createInitFile()
//        }
        
//        let timeStampFileName = "DeviceData/TimeStamp.json"
//        let timeStampFileURL = dir.appendingPathComponent(timeStampFileName)
//
//        let isTimeStampExist: Bool = FileManager.default.fileExists(atPath: timeStampFileURL.path)
//        if isTimeStampExist == false {
//            createInitFile()
//        }

//        if isDeviceDataExist == false || isTimeStampExist == false {
        if cExit == false || tExit == false {
            print("not exist json files")
            // JSONファイルが存在しない場合、InitialViewを表示する
            let initialView = InitialView()
            
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: initialView)
                self.window = window
                window.makeKeyAndVisible()
            }
        } else {
            guard let _ = (scene as? UIWindowScene) else { return }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        // ここでの読み込みはやめる
//        completionModel = loadOnDevice(fileURL)
//        timeStamp = loadOnDevice(timeStampFileURL)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // 存在check関数
    func createInitFile() {
        let tmpDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tmpFile = "ここにデータを置いてください"
        let tmpFIleURL = tmpDir.appendingPathComponent(tmpFile)
        FileManager.default.createFile(atPath: tmpFIleURL.path, contents: nil, attributes: nil)
        print("初期化処理を完了しました。: ", tmpFIleURL.path)
    }
}

