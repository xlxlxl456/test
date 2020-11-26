//
//  UIViewController+.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/24.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlert(
        title:          String? = nil,
        message:        String? = nil,
       cancelButton:    Bool = false,
       actionTitle:     String = "OK",
       action:          (() -> Void)? = nil)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if cancelButton { alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel)) }
        alert.addAction(UIAlertAction(title: actionTitle, style: cancelButton ? .default : .cancel, handler: { _ in
            action?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(
        style:      UIAlertController.Style = .alert,
        title:      String? = nil,
        message:    String? = nil,
        actions:    [(title: String, action: (() -> Void)?)])
    {    
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { (title, action) in
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                    action?()
            }))
        }
        present(alert, animated: true, completion: nil)
    }
    
    func showSetting(_ useage: String) {
        showAlert(title: "\(useage)へのアクセスを許可する",
                  message: "\"設定\"からアクセスを許可してください。",
                  actionTitle: "設定",
                  action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
        })
    }
}
