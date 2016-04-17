//
//  OnePresence.swift
//  OneChat
//
//  Created by Victor Belenko on 22/02/2015.
//  Copyright (c) 2016 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

// MARK: Protocol
public protocol OnePresenceDelegate {
	func onePresenceDidReceivePresence()
}

public class OnePresence: NSObject {
	var delegate: OnePresenceDelegate?
    
	// MARK: Singleton
	
	class var sharedInstance : OnePresence {
		struct OnePresenceSingleton {
			static let instance = OnePresence()
		}
		return OnePresenceSingleton.instance
	}
	
	// MARK: Functions
	
	class func goOnline() {
		let presence = XMPPPresence()
		let domain = OneChat.sharedInstance.xmppStream!.myJID.domain
		
		if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
			let priority: DDXMLElement = DDXMLElement(name: "priority", stringValue: "24")
			presence.addChild(priority)
		}
		
		OneChat.sharedInstance.xmppStream?.sendElement(presence)
	}
	
	class func goOffline() {
		var _ = XMPPPresence(type: "unavailable")
	}
}

extension OnePresence: XMPPStreamDelegate {
	
	public func xmppStream(sender: XMPPStream, didReceivePresence presence: XMPPPresence) {
		print("did received presence : \(presence)")
        let type = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        if presenceFromUser != myUsername {
            if type == "available" {
                
            } else if type == "unavailable" {
                
            } else if type == "subscribe" {
                
                OneRoster.sharedInstance.acceptBuddyRequestFrom(presence.from().bare())
            }
        }
	}
    public func xmppStream(sender: XMPPStream!, didSendPresence presence: XMPPPresence!) {
        print("did sent presense: \(presence)")
    }
    public func xmppStream(sender: XMPPStream!, didFailToSendPresence presence: XMPPPresence!, error: NSError!) {
        print("failed to send")
    }
}