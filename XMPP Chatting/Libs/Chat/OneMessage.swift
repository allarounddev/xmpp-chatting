//
//  OneMessage.swift
//  OneChat
//
//  Created by Victor Belenko on 22/02/2016.
//  Copyright (c) 2016 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public typealias OneChatMessageCompletionHandler = (stream: XMPPStream, message: XMPPMessage) -> Void

// MARK: Protocols

public protocol OneMessageDelegate : NSObjectProtocol {
	func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
	func oneStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject)
}

public class OneMessage: NSObject {
	public weak var delegate: OneMessageDelegate?
	
	public var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
	var xmppMessageArchiving: XMPPMessageArchiving?
	var didSendMessageCompletionBlock: OneChatMessageCompletionHandler?
    
    var willSendMessageBlock: (msg: XMPPMessage)->Void = {arg in}
    var sendMessageFailedBlock: (msg: XMPPMessage)-> Void = {arg in}
    var didSendMessageBlock:(msg: XMPPMessage)-> Void = {arg in}
	
	// MARK: Singleton
	
	public class var sharedInstance : OneMessage {
		struct OneMessageSingleton {
			static let instance = OneMessage()
		}
		
		return OneMessageSingleton.instance
	}
	
	// MARK: private methods
	
	func setupArchiving() {
		xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
		xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
		
		xmppMessageArchiving?.clientSideMessageArchivingOnly = true
		xmppMessageArchiving?.activate(OneChat.sharedInstance.xmppStream)
		xmppMessageArchiving?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
	}
	
	// MARK: public methods
	
	public class func sendMessage(message: String, to receiver: String, completionHandler completion:OneChatMessageCompletionHandler) {
		let body = DDXMLElement.elementWithName("body") as! DDXMLElement
		let messageID = OneChat.sharedInstance.xmppStream?.generateUUID()
		
		body.setStringValue(message)
		
		let completeMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
		
		completeMessage.addAttributeWithName("id", stringValue: messageID)
		completeMessage.addAttributeWithName("type", stringValue: "chat")
		completeMessage.addAttributeWithName("to", stringValue: receiver)
		completeMessage.addChild(body)
		
		sharedInstance.didSendMessageCompletionBlock = completion
		OneChat.sharedInstance.xmppStream?.sendElement(completeMessage)
	}
    
    public class func sendImage(link: String, to receiver: String, width: CGFloat, height: CGFloat) {
        let body = DDXMLElement.elementWithName("body") as! DDXMLElement
        let messageID = OneChat.sharedInstance.xmppStream?.generateUUID()
        
        body.setStringValue(link)
        
        let completeMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
        
        completeMessage.addAttributeWithName("id", stringValue: messageID)
        completeMessage.addAttributeWithName("type", stringValue: "image")
        completeMessage.addAttributeWithName("to", stringValue: receiver)
        completeMessage.addChild(body)
        completeMessage.addAttributeWithName("width", floatValue: Float(width))
        completeMessage.addAttributeWithName("height", floatValue: Float(height))
        
        OneChat.sharedInstance.xmppStream?.sendElement(completeMessage)
        
    }
	
	public class func sendIsComposingMessage(recipient: String, completionHandler completion:OneChatMessageCompletionHandler) {
		if recipient.characters.count > 0 {
			let message = DDXMLElement.elementWithName("message") as! DDXMLElement
			message.addAttributeWithName("type", stringValue: "chat")
			message.addAttributeWithName("to", stringValue: recipient)
			
			let composing = DDXMLElement.elementWithName("composing", stringValue: "http://jabber.org/protocol/chatstates") as! DDXMLElement
			message.addChild(composing)
			
			sharedInstance.didSendMessageCompletionBlock = completion
			OneChat.sharedInstance.xmppStream?.sendElement(message)
		}
	}
	
	public func loadArchivedMessagesFrom(jid jid: String) -> [AnyObject]? {
		let moc = xmppMessageStorage?.mainThreadManagedObjectContext
		let entityDescription = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: moc!)
		let request = NSFetchRequest()
		let predicateFormat = "bareJidStr like %@ "
		let predicate = NSPredicate(format: predicateFormat, jid)
		
		request.predicate = predicate
		request.entity = entityDescription
		
		do {
			let results = try moc?.executeFetchRequest(request)
			
            return results
		} catch _ {
			//catch fetch error here
		}
		return nil
	}
    
    public func deleteAllMessages() {
        let moc = self.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: moc!)
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        do {
            let results = try moc?.executeFetchRequest(request)
            
            for message in results! {
                moc?.deleteObject(message as! NSManagedObject)
                
            }
        } catch _ {
            //catch fetch error here
        }
    }
	
	public func deleteMessagesFrom(jid jid: String, messages: NSArray) {
		messages.enumerateObjectsUsingBlock { (message, idx, stop) -> Void in
			let moc = self.xmppMessageStorage?.mainThreadManagedObjectContext
			let entityDescription = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: moc!)
			let request = NSFetchRequest()
			let predicateFormat = "messageStr like %@ "
			let predicate = NSPredicate(format: predicateFormat, message as! String)
			
			request.predicate = predicate
			request.entity = entityDescription
			
			do {
				let results = try moc?.executeFetchRequest(request)
				
				for message in results! {
					var element: DDXMLElement!
					do {
						element = try DDXMLElement(XMLString: message.messageStr)
					} catch _ {
						element = nil
					}
					
					if element.attributeStringValueForName("messageStr") == message as! String {
						moc?.deleteObject(message as! NSManagedObject)
					}
				}
			} catch _ {
				//catch fetch error here
			}
		}
	}
}

extension OneMessage: XMPPStreamDelegate {
	
	public func xmppStream(sender: XMPPStream, didSendMessage message: XMPPMessage) {
		if let completion = OneMessage.sharedInstance.didSendMessageCompletionBlock {
			completion(stream: sender, message: message)
		}
        OneMessage.sharedInstance.didSendMessageBlock(msg: message)
		//OneMessage.sharedInstance.didSendMessageCompletionBlock!(stream: sender, message: message)
	}
    
    public func xmppStream(sender: XMPPStream!, didFailToSendMessage message: XMPPMessage!, error: NSError!) {
        OneMessage.sharedInstance.sendMessageFailedBlock(msg: message)
    }
    public func xmppStream(sender: XMPPStream!, willSendMessage message: XMPPMessage!) -> XMPPMessage! {
        OneMessage.sharedInstance.willSendMessageBlock(msg: message)
        return message
    }
	
	public func xmppStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage) {
        print(message)
		let auser = OneChat.sharedInstance.xmppRosterStorage.userForJID(message.from(), xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: OneRoster.sharedInstance.managedObjectContext_roster())
        guard let user = auser else {
            
            return
        }
        if let _ = user.jidStr {
            if !OneChats.knownUserForJid(jidStr: user.jidStr) {
                OneChats.addUserToChatList(jidStr: user.jidStr)
            }
        }
		
		
		if message.isChatMessageWithBody() {
			OneMessage.sharedInstance.delegate?.oneStream(sender, didReceiveMessage: message, from: user)
		} else {
            if message.attributeStringValueForName("type") == "image" {
                OneMessage.sharedInstance.delegate?.oneStream(sender, didReceiveMessage: message, from: user)
            } else {
                //was composing
                if let _ = message.elementForName("composing") {
                    OneMessage.sharedInstance.delegate?.oneStream(sender, userIsComposing: user)
                }
            }
			
		}
	}
}

