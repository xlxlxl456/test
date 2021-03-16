//
//  WKWebView.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2019/12/29.
//  Copyright © 2019 FURUKAWA ELECTRIC CO., LTD. All rights reserved.
//

import WebKit

/// adding "console.log" support
extension WKWebView: WKScriptMessageHandler {
    
    /// enabling console.log
    public func enableConsoleLog() {
        
        //    set message handler
        configuration.userContentController.add(self, name: "logging")
        
        //    override console.log
        let _override = WKUserScript(source: "var console = { log: function(msg){window.webkit.messageHandlers.logging.postMessage(msg) }};", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(_override)
    }
    
    /// message handler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print("WebView: ", message.body)
    }
}
