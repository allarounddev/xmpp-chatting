//
//  OneRoster.swift
//  OneChat
//
//  Created by Victor Belenko on 22/02/2015.
//  Copyright (c) 2016 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public protocol OneRosterDelegate {
	func oneRosterContentChanged(controller: NSFetchedResultsController)
}

public class OneRoster: NSObject, NSFetchedResultsControllerDelegate {
	public var delegate: OneRosterDelegate?
	public var fetchedResultsControllerVar: NSFetchedResultsController?
    
	// MARK: Singletonsen
	
	public class var sharedInstance : OneRoster {
		struct OneRosterSingleton {
			static let instance = OneRoster()
		}
		return OneRosterSingleton.instance
	}
	
	public class var buddyList: NSFetchedResultsController {
		get {
			if sharedInstance.fetchedResultsControllerVar != nil {
				return sharedInstance.fetchedResultsControllerVar!
			}
			return sharedInstance.fetchedResultsController()!
		}
	}
	
	// MARK: Core Data
	
	func managedObjectContext_roster() -> NSManagedObjectContext {
		return OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
	}
	
	private func managedObjectContext_capabilities() -> NSManagedObjectContext {
		return OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
	}
	
	public func fetchedResultsController() -> NSFetchedResultsController? {
		if fetchedResultsControllerVar == nil {
			let moc = OneRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
			let entity = NSEntityDescription.entityForName("XMPPUserCoreDataStorageObject", inManagedObjectContext: moc!)
			let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
			let sd2 = NSSortDescriptor(key: "displayName", ascending: true)
			
			let sortDescriptors = [sd1, sd2]
			let fetchRequest = NSFetchRequest()
			
			fetchRequest.entity = entity
			fetchRequest.sortDescriptors = sortDescriptors
			fetchRequest.fetchBatchSize = 10
			
			fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
			fetchedResultsControllerVar?.delegate = self
			
			do {
				try fetchedResultsControllerVar!.performFetch()
			} catch let error as NSError {
				print("Error: \(error.localizedDescription)")
				abort()
			}
			//  if fetchedResultsControllerVar?.performFetch() == nil {
			//Handle fetch error
			//}
		}
		
		return fetchedResultsControllerVar!
	}
	
	public class func userFromRosterAtIndexPath(indexPath indexPath: NSIndexPath) -> XMPPUserCoreDataStorageObject {
		return sharedInstance.fetchedResultsController()!.objectAtIndexPath(indexPath) as! XMPPUserCoreDataStorageObject
	}
	
	public class func userFromRosterForJID(jid jid: String) -> XMPPUserCoreDataStorageObject? {
		let userJID = XMPPJID.jidWithString(jid)
		
		if let user = OneChat.sharedInstance.xmppRosterStorage.userForJID(userJID, xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: sharedInstance.managedObjectContext_roster()) {
			return user
		} else {
			return nil
		}
	}
	
	public class func removeUserFromRosterAtIndexPath(indexPath indexPath: NSIndexPath) {
		let user = userFromRosterAtIndexPath(indexPath: indexPath)
		sharedInstance.fetchedResultsControllerVar?.managedObjectContext.deleteObject(user)
	}
	
	public func controllerDidChangeContent(controller: NSFetchedResultsController) {
		delegate?.oneRosterContentChanged(controller)
	}
    
}

extension OneRoster: XMPPRosterDelegate {
	
	public func xmppRoster(sender: XMPPRoster, didReceiveBuddyRequest presence:XMPPPresence) {
		//was let user
		_ = OneChat.sharedInstance.xmppRosterStorage.userForJID(presence.from(), xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: managedObjectContext_roster())
	}
	
	public func xmppRosterDidEndPopulating(sender: XMPPRoster?) {
		let jidList = OneChat.sharedInstance.xmppRosterStorage.jidsForXMPPStream(OneChat.sharedInstance.xmppStream)
		print("List=\(jidList)")
		
	}
	
	public func sendBuddyRequestTo(username: String) {
//		let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
//		presence.addAttributeWithName("type", stringValue: "subscribe")
//        	presence.addAttributeWithName("to", stringValue: username)
//        	presence.addAttributeWithName("from", stringValue: OneChat.sharedInstance.xmppStream?.myJID.bare())
//        
//        OneChat.sharedInstance.xmppStream?.sendElement(presence)
        
        OneChat.sharedInstance.xmppRoster?.addUser(XMPPJID.jidWithString(username), withNickname: "Test Nickname")
    }
    	
    	public func acceptBuddyRequestFrom(username: String) {
//        	let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
//        	presence.addAttributeWithName("to", stringValue: username)
//        	presence.addAttributeWithName("from", stringValue: OneChat.sharedInstance.xmppStream?.myJID.bare())
//        	presence.addAttributeWithName("type", stringValue: "subscribed")
//        	
//        	OneChat.sharedInstance.xmppStream?.sendElement(presence)
            
            OneChat.sharedInstance.xmppRoster?.acceptPresenceSubscriptionRequestFrom(XMPPJID.jidWithString(username), andAddToRoster: true)
    	}
    
    	public func declineBuddyRequestFrom(username: String) {
            OneChat.sharedInstance.xmppRoster?.rejectPresenceSubscriptionRequestFrom(XMPPJID.jidWithString(username))
            
//        	let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
//        	presence.addAttributeWithName("to", stringValue: username)
//        	presence.addAttributeWithName("from", stringValue: OneChat.sharedInstance.xmppStream?.myJID.bare())
//        	presence.addAttributeWithName("type", stringValue: "unsubscribed")
//
//        	OneChat.sharedInstance.xmppStream?.sendElement(presence)
    	}
}

extension OneRoster: XMPPStreamDelegate {
	
	public func xmppStream(sender: XMPPStream, didReceiveIQ ip: XMPPIQ) -> Bool {
		if let msg = ip.attributeForName("from") {
			if msg.stringValue() == "conference.process-one.net"  {
				
			}
		}
		return false
	}
    
}
