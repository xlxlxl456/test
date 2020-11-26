//
//  WebViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/16.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    var webView: WKWebView?
    private let jsManager = JavaScriptManager()
    private var takePhoto: (([UIImagePickerController.InfoKey : Any]?) -> Void)?
    
    class func openFacility(serialNumber: String, from: UIViewController) {
        Facility.loadCurrent(serialNumber: serialNumber)
        DataManager.linkImages(facilitySn: serialNumber)
        let webVC = WebViewController()
        webVC.modalPresentationStyle = .fullScreen
        from.present(webVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsManager.webViewController = self
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "iOSNative")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView( frame: view.bounds, configuration: config)
        self.webView = webView
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        view.backgroundColor = .white
        
        let url = URL(fileURLWithPath: DataManager.webPath)
        webView.loadFileURL(url.appendingPathComponent("facility.html"), allowingReadAccessTo: url)
        
        if Facility.current?.facilityItem?.facility?.inspectionDeviceStatus != .some(.inspected) {
            jsManager.updateInspectionDeviceStatus(.inspecting, save: true, completed: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DeviceLog.save()
    }
    
    func close() {
        dismiss(animated: true)
        Facility.current = nil
        DataManager.delinkImages()
    }
    
    func openCamera(_ completion: (([UIImagePickerController.InfoKey : Any]?) -> Void)?) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion?(nil)
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
        takePhoto = completion
    }
}

extension WebViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        takePhoto?(info)
        takePhoto = nil
        picker.dismiss(animated: true) { [weak self] in
            self?.webView?.reload()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        takePhoto?(nil)
        takePhoto = nil
        picker.dismiss(animated: true) { [weak self] in
            self?.webView?.reload()
        }
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let array = prompt.components(separatedBy: ".")
        if array.first == JavaScriptManager.interfaceName, let method = array.last {
            // iOSNative.jsでのfetchFromNativeより呼ばれ、jsManagerに処理させ、結果を返す
            completionHandler(jsManager.fetch(method, params: defaultText))
        } else {
            completionHandler(nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "確認", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        present(alert, animated: true)
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // iOSNative.jsでのcallNativeより呼ばれ、jsManagerに処理させる
        if message.name == JavaScriptManager.interfaceName,
            let body = message.body as? [String: Any],
            let method = body["method"] as? String {
            let params = body["params"]
            jsManager.execute(method, params: params)
        }
    }
}
