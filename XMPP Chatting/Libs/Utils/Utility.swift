//
//  Utility.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 2/23/16.
//  Copyright © 2016 tutacode. All rights reserved.
//

import Foundation
import UIKit
import TWMessageBarManager
import MBProgressHUD

// Notification
func showInfoNotification(title title: String?, desc: String?) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle(title, description: desc, type: .Info)
}
func showSuccessNotification(description desc: String?) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle("Success", description: desc, type: .Success)
}
func showErrorNotification(description desc: String?) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle("Error", description: desc, type: .Error)
}

// HUD
func showHudOnView(view: UIView, title: String? = nil)-> MBProgressHUD {
    let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
    if let _ = title {
        hud.labelText = title!
    }
    return hud
}
func removeAllHudOnView(view: UIView) {
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }
}
func showHudOnView(view: UIView, title: String? = nil, dismissAfter: NSTimeInterval) {
    let hud = showHudOnView(view, title: title)
    hud.mode = .Text
    hud.hide(true, afterDelay: dismissAfter)
}