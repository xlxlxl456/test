//
//  ActivationViewController.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/08/26.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

final class ActivationViewController: UITableViewController {
    

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var button: UIButton!
    
    private lazy var indicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //　上下のセンターリング
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            let contentHeight = CGFloat(266 + 102) //storyboardに依存
            let margin = (window.frame.height - contentHeight) / 2
            let view = UIView(frame: .init(origin: .zero, size: .init(width: window.frame.width, height: margin)))
            tableView.tableHeaderView = view
            tableView.tableFooterView = view
        }
        button.isEnabled = false
        button.alpha = 0.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @IBAction func inputDidChange(_ sender: UITextField) {
        button.isEnabled = textField.text?.isEmpty != true
        button.alpha = button.isEnabled ? 1 : 0.5
    }
    
    @IBAction func activate(_ sender: Any) {
        activate()
    }
    
    private func activate() {
        view.endEditing(false)
        view.isUserInteractionEnabled = false
        
        view.addSubview(indicator)
        indicator.center = view.center
        indicator.startAnimating()
        
        let serialNumber = textField.text ?? ""
        let id = UUID().uuidString
        
        activat(serialNumber: serialNumber, id: id) { [weak self] date in
            
            guard let expiration = date, DataManager.save(expiration: expiration, id: id) else {
                self?.activationDidFinish(errorMessage: "アクティベーションに失敗しました。")
                return
            }
            
            guard expiration > Date() else {
                self?.activationDidFinish(errorMessage: "有効期限が切れています。")
                return
            }
            
            self?.validate(serialNumber: serialNumber) { success in
                self?.activationDidFinish(errorMessage: success ? nil : "アクティベーションに失敗しました。")
            }
        }
    }
    
    private func activat(serialNumber: String, id: String, completion: ((Date?) -> Void)?) {
        let url = URL(string: "https://fsangyo.xsrv.jp/inspection/app_dl.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = "serial=\(serialNumber)&key=\(id)".data(using: .utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // レスポンスフォーマット："OK:0c377e4b715c5972ccf648be417cee9615f053bcb740d2528ef22bee3c731f0f,45747"
            if error == nil,
                let data = data,
                let result = String(data: data, encoding: .utf8),
                result.components(separatedBy: ":").first == "OK",
                let expiration = result.components(separatedBy: ",").last,
                let daysUNIX = TimeInterval(expiration) {
                // 25569: UNIX Time の基準時刻 (1970/01/01(木) 00:00:00 UTC) に相当するシリアル値
                let daysFrom1970 = daysUNIX - 25569
                let date = Date(timeIntervalSince1970: daysFrom1970 * 3600 * 24)
                    .addingTimeInterval(3600 * 9)   //日本時間にする
                completion?(date)
            } else {
                completion?(nil)
            }
        }.resume()
    }
    
    private func validate(serialNumber: String, completion: ((Bool) -> Void)?) {
        let url = URL(string: "https://fsangyo.xsrv.jp/inspection/app_done.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = "serial=\(serialNumber)".data(using: .utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil,
                let data = data,
                let result = String(data: data, encoding: .utf8),
                result.components(separatedBy: ":").first == "OK" {
                completion?(true)
            } else {
                completion?(false)
            }
        }.resume()
    }
    
    private func activationDidFinish(errorMessage: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.indicator.stopAnimating()
            self.indicator.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            
            if let errorMessage = errorMessage {
                DataManager.deleteExpiration()
                self.showAlert(title: "エラー", message: errorMessage)
            } else {
                (UIApplication.shared.delegate as? AppDelegate)?
                .transitionRootViewController(storyboardIdentifier: "ARViewController")
            }
        }
    }
}

extension ActivationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty != true {
            activate()
            return true
        }
        return false
    }
}
