//
//  ViewController.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2019/12/14.
//  Copyright © 2019 FURUKAWA ELECTRIC CO., LTD. All rights reserved.
//

import UIKit
import WebKit
import SwiftUI

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // JavaScript
        setJS()
        
        // read Local HTML
        let path: String = Bundle.main.path(forResource: "html/Top/top", ofType: "html")!
        let localHtmlUrl: URL = URL(fileURLWithPath: path)

        webView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
        
        // Show JavaScript Console
        webView.enableConsoleLog()
    }
    
    // MARK:- Access JavaScript
    
    /*************************************
     *
     *  JSコントローラ設定
     *
     ************************************/
    func setJS(){
        
        let userController: WKUserContentController = WKUserContentController()
        userController.add(self, name: "loadDirectory")         // load work dir
        userController.add(self, name: "loadCompletionList")    //
        userController.add(self, name: "loadHtml")              // 画面切り替え
        
        userController.add(self, name: "loadCurrentData")       // JSONデータ取得
        
        userController.add(self, name: "setPoleNum")
        userController.add(self, name: "loadPoleNum")
        
        userController.add(self, name: "saveJSON")              // データ保存
        userController.add(self, name: "saveTimeStamp")         // タイムスタンプ保存
        
        userController.add(self, name: "loadImageSrc")          // 画像パス取得
        userController.add(self, name: "gotoCamera")            // カメラ呼び出し
        
        userController.add(self, name: "setImageFiles")         // 画像リスト
        
        userController.add(self, name: "addNote")
        
        let webConfig: WKWebViewConfiguration = WKWebViewConfiguration()
        webConfig.userContentController = userController
        webConfig.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        // js -> nativfe
        webView = WKWebView(frame: self.view.bounds, configuration: webConfig)
        
        // 画面回転に対応
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // デリゲート
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
    }
    
    /* JSコントローラ内処理 */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "loadDirectory" {
            // get directory names
            var dir: [String] = []
            for d in dirs {
                if d.contains(".DS_Store") || d.contains("ここにデータを置いてください") || d.contains(".Trash"){
                }
                else {
                    dir.append(d)
                }
            }
            
            // set directory names into js
            let execJsFunc: String = "setDirectoryData(\(dir))"
            webView.evaluateJavaScript(execJsFunc, completionHandler: nil)
        }
        
        if message.name == "loadCompletionList" {
            let sDir = message.body as! String
            
            // set currentDir
            currentDir = sDir
            
            // load selected work's json
            let tDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let cJSON = "\(sDir)/DeviceData/Completion.json"
            fileURL = tDir.appendingPathComponent(cJSON)
            completionModel = loadOnDevice(fileURL)
            
            let tJSON = "\(sDir)/DeviceData/TimeStamp.json"
            timeStampFileURL = dir.appendingPathComponent(tJSON)
            timeStamp = loadOnDevice(timeStampFileURL)
            
            // load completionList
            let path: String = Bundle.main.path(forResource: "html/CompletionList/completionList", ofType: "html")!
            let localHtmlUrl: URL = URL(fileURLWithPath: path)
            webView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
        }
        
        // ページ遷移
        if message.name == "loadHtml" {
            // 工事一覧
            if message.body as! String == "workList" {
                let path: String = Bundle.main.path(forResource: "html/WorkList/workList", ofType: "html")!
                let localHtmlUrl: URL = URL(fileURLWithPath: path)
                webView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
            }
            // 10件表示
            else if message.body as! String == "completionList" {
                let path: String = Bundle.main.path(forResource: "html/CompletionList/completionList", ofType: "html")!
                let localHtmlUrl: URL = URL(fileURLWithPath: path)
                webView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
            }
            // 確認票
            else if message.body as! String == "completion" {
                let path: String = Bundle.main.path(forResource: "html/Completion/completion", ofType: "html")!
                let localHtmlUrl: URL = URL(fileURLWithPath: path)
                webView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
            }
        }
        
        // load current completion
        if message.name == "loadCurrentData" {
            completionModel = loadOnDevice(fileURL)
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(completionModel)
            let str = String(data: encoded, encoding: .utf8)
            let execJsFunc: String = "setCurrentData(\(str!));"
            webView.evaluateJavaScript(execJsFunc, completionHandler: nil)
        }
                
        // set pole number from js
        if message.name == "setPoleNum" {
            poleNum = Int((message.body as! NSString).intValue)
        }
        
        // load pole number to js
        if message.name == "loadPoleNum" {
            let execJsFunc: String = "setPoleNum(\(poleNum))"
            webView.evaluateJavaScript(execJsFunc, completionHandler: nil)
        }
        
        // load image src
        if message.name == "loadImageSrc" {
        
            if completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoName != "" {
            
                let unique_2 = NSHomeDirectory() + "/Documents/\(currentDir)/DeviceData/Images/\(poleNum)/"
                if FileManager.default.fileExists(atPath: unique_2) {
                
                    let unique_3 = unique_2 + completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoName!

                    let img = UIImage(contentsOfFile: unique_3)
                    if img != nil {
                        let imgData: NSData = img!.jpegData(compressionQuality: 1.0)! as NSData
                        let imgStr = imgData.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
                        webView.evaluateJavaScript("setImageSrc(0, \"\(imgStr)\");", completionHandler: nil)
                    }
                }
            }
            
            if completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoName != "" {
            
                let unique_2 = NSHomeDirectory() + "/Documents/\(currentDir)/DeviceData/Images/\(poleNum)/"
                if FileManager.default.fileExists(atPath: unique_2) {
                
                    let unique_3 = unique_2 + completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoName!
                    
                    let img = UIImage(contentsOfFile: unique_3)
                    if img != nil {
                        let imgData: NSData = img!.jpegData(compressionQuality: 1.0)! as NSData
                        let imgStr = imgData.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
                        webView.evaluateJavaScript("setImageSrc(1, \"\(imgStr)\");", completionHandler: nil)
                    }
                }
            }
        }
        
        // goto camera
        if message.name == "gotoCamera" {
            state = message.body as! Int
            startCamera()
        }
        
        if message.name == "addNote" {
            addNote()
        }
        
        if message.name == "setImageFiles" {
            var files: [String] = []
            // いまの工事の、いまのポール番号のフォルダ内を取得
            let dirURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dStr = "\(currentDir)/DeviceData/Images/\(poleNum)/"
            let dURL = dirURL.appendingPathComponent(dStr)
            do {
                let contentUrls = try FileManager.default.contentsOfDirectory(at: dURL, includingPropertiesForKeys: nil)
                files = contentUrls.map{$0.lastPathComponent}
            } catch {
                print("error: failed get document directory info")
            }
            
            if 0 < files.count {
                var buf: [String] = []
                for f in files {
                    print(f)
                    // if jpg file, append res[]
                    if f.contains(".jpg") {
                        buf.append(f)
                    }
                }
                // sort ascending
                buf.sort()
                
                let fileName = message.body as! String
                let execJsFunc: String = "setOption(\(buf), \"\(fileName)\");"
                webView.evaluateJavaScript(execJsFunc, completionHandler: nil)
            }
        }
        
        // save json
        if message.name == "saveJSON" {
            let json: Data? = (message.body as! NSString).data(using: String.Encoding.utf8.rawValue)
            do {
                completionModel = try JSONDecoder().decode(CompletionModel.self, from: json!)
                saveEntriesToJson();
            } catch {
                print("error: ", error.localizedDescription)
            }
        }
        
        // save timestamp
        if message.name == "saveTimeStamp" {
            let str = String(message.body as! NSString)
            let strs: [String] = str.components(separatedBy: ",")
            
            var log: TimeStamp.TimeStampModelItems = TimeStamp.TimeStampModelItems(
                PoleNum: poleNum,
                PoleNumber: completionModel.JointUseModels[poleNum - 1].PoleNumber,
                Action: strs[0],
                TimeStampType: Int(strs[1]))
                
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let now = Date()
            log.TimeStamp = f.string(from: now)
            
            timeStamp.Logs.append(log)
            saveLogsToJson()
        }
    }
    
    
    /* Camera */
    func startCamera(){
        let sourceType:UIImagePickerController.SourceType =
            UIImagePickerController.SourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerController.SourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        guard let uiImage = info[.originalImage] as? UIImage else {
            print("no image found")
            return
        }
        
        // create save folder
        // 保存先を電柱番号からリストの番号に変更
//        let unique_1 = completionModel.JointUseModels[poleNum - 1].PoleNumber!
//        let cameraURL_string = NSHomeDirectory() + "/Documents/DeviceData/Images/" + unique_1 + "/"
        let cameraURL_string = NSHomeDirectory() + "/Documents/\(currentDir)/DeviceData/Images/\(poleNum)/"
        createDir(dirPath: cameraURL_string)
        
        // get date
        let f = DateFormatter()
        f.dateFormat = "yyyyMMddHHmmss"
        let now = Date()
        
        // set file path with name
        let unique_1 = completionModel.JointUseModels[poleNum - 1].PoleNumber!
        let unique_2 = unique_1 + "_"
        let unique_3 = unique_2 + f.string(from: now) + ".jpg"
        let filename = cameraURL_string + unique_3
        let imageURL: URL = URL(fileURLWithPath: filename)
        
        // Exifデータ(メタデータ)も一緒にJPEG画像に保存する
        let imageData = uiImage.jpegData(compressionQuality: 0.8)
        let src = CGImageSourceCreateWithData(imageData! as CFData, nil)!
        let uti = CGImageSourceGetType(src)!
        let cfPath = CFURLCreateWithFileSystemPath(nil, imageURL.path as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let dest = CGImageDestinationCreateWithURL(cfPath!, uti, 1, nil)
        
        let metadata = info[UIImagePickerController.InfoKey.mediaMetadata] as? NSDictionary
        CGImageDestinationAddImageFromSource(dest!, src, 0, metadata!)
        if (CGImageDestinationFinalize(dest!)) {
            print("Saved image with metadata!")
        } else {
            print("Error saving image with metadata")
        }
        
        // save json
        // not need to save timestamp
        f.dateFormat = "yyyy/MM/dd"
        var photoNum: Int = 0
        if state == 0 {
            photoNum = completionModel.JointUseModels[poleNum - 1].BeforeModelItems.Photos.count
        }
        else {
            photoNum = completionModel.JointUseModels[poleNum - 1].AfterModelItems.Photos.count
        }
        print("poleNum: \(poleNum)")
        print("state: \(state)")
        print("photoNum: \(photoNum)")
        let photo: CompletionModel.Photo = CompletionModel.Photo(
            PhotoDate: f.string(from: now),
            PhotoNumber: photoNum + 1,
            PhotoSrc: unique_3,
            PhotoName: unique_3)
        
        if state == 0 {
            print("before photos.count: \(completionModel.JointUseModels[poleNum - 1].BeforeModelItems.Photos.count)")
            completionModel.JointUseModels[poleNum - 1].BeforeModelItems.Photos.append(photo)
            completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoDate = photo.PhotoDate
            completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoNumber = photo.PhotoNumber
            completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoSrc = photo.PhotoSrc
            completionModel.JointUseModels[poleNum - 1].BeforeModelItems.PhotoName = photo.PhotoName
            print("before photos.count: \(completionModel.JointUseModels[poleNum - 1].BeforeModelItems.Photos.count)")
        }
        else {
            print("after photos.count: \(completionModel.JointUseModels[poleNum - 1].AfterModelItems.Photos.count)")
            completionModel.JointUseModels[poleNum - 1].AfterModelItems.Photos.append(photo)
            completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoDate = photo.PhotoDate
            completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoNumber = photo.PhotoNumber
            completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoSrc = photo.PhotoSrc
            completionModel.JointUseModels[poleNum - 1].AfterModelItems.PhotoName = photo.PhotoName
            print("after photos.count: \(completionModel.JointUseModels[poleNum - 1].AfterModelItems.Photos.count)")
        }
        saveEntriesToJson()

        // reload current completion
        let execJsFunc: String = "fromCamera()"
        webView.evaluateJavaScript(execJsFunc, completionHandler: nil)
        
        //閉じる処理
        imagePicker.dismiss(animated: true, completion: nil)
        print("take photo")
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("take cancel")
    }
    
    //Fucntion to craete dir specified by dirPath
    func createDir(dirPath: String){
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("ERROR")
            print(error)
        }
    }
    
    func addNote() {
        self.present(UIHostingController(rootView: NewDrawing()), animated: true)
    }
    
    /* Write JSON File */
    
    func saveEntriesToJson() {
        print("saveEntriesToJson")
        let data = try! JSONEncoder().encode(completionModel)
        let dataStr = String(data: data, encoding: .utf8)
        if dataStr?.isEmpty ?? true { return }
        do {
            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // fix path
            let fileName = "\(currentDir)/DeviceData/Completion.json"
            let fileURL = dir.appendingPathComponent(fileName)
            try dataStr!.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch _ {
            print("Write Error")
        }
    }
    
    func saveLogsToJson() {
        let data = try! JSONEncoder().encode(timeStamp)
        let dataStr = String(data: data, encoding: .utf8)
        if dataStr?.isEmpty ?? true { return }
        do {
            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // fix path
            let fileName = "\(currentDir)/DeviceData/TimeStamp.json"
            let fileURL = dir.appendingPathComponent(fileName)
            try dataStr!.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch _ {
            print("Write Error")
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: NewDrawing()) {
                EmptyView()
            }
        }
    }
}

