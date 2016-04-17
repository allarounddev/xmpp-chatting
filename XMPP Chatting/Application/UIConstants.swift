//
//  UIConstants.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 2/25/16.
//  Copyright © 2016 tutacode. All rights reserved.
//
import Foundation
import UIKit
import ChameleonFramework

struct AppStyle {
    static let mainColor = UIColor.flatBlueColor()
    static let tintColor = UIColor.flatYellowColor()
}


struct MainStoryboard {
    struct Segues {
        static let showChatView = "showChatView"
        static let addBuddySegue = "addBuddySegue"
    }
}