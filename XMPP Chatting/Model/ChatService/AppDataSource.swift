//
//  AppDataSource.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 26/02/2015.
//  Copyright (c) 2016 ProcessOne. All rights reserved.
//

import Foundation
import Chatto
import XMPPFramework

class AppDataSource: ChatDataSourceProtocol {
    var nextMessageId: Int = 0
    let preferredMaxWindowSize = 500
    var recipient: XMPPUserCoreDataStorageObject?
    
    var messages = [ChatItemProtocol]()
    
    init(sender: XMPPUserCoreDataStorageObject?) {
        self.recipient = sender
        listenEventOneMessage()
        loadArchivedMessages()
    }
    
    deinit {
        
    }
    
    // listen message send notifications
    func listenEventOneMessage() {
        // when message start sending, we add to datasource with status is Sending
        OneMessage.sharedInstance.willSendMessageBlock = { (msg: XMPPMessage)-> Void in
            let displayName = OneChat.sharedInstance.xmppStream?.myJID
            let sender = displayName!.bare()
            if let type = msg.type() {
                if let _ = msg.body() {
                    if type == "chat" {
                        let msg = createTextMessageModel(String(self.nextMessageId), senderId: sender, text: msg.body(), date: NSDate(), isIncoming: false, status: .Sending, msg: msg)
                        self.messages.append(msg)
                        self.nextMessageId++
                        self.delegate?.chatDataSourceDidUpdate(self)
                    } else if type == "image" {
                        // do nothing because we already added
                    }
                }
                
            }
        }
        
        // when message failed to send, find that message on datasource and change status to .Failed and update tableview
        OneMessage.sharedInstance.sendMessageFailedBlock = { (msg: XMPPMessage)-> Void in
            let count = self.messages.count
            for var i = count-1; i >= 0; i-- {
                let obj = self.messages[i]
                if obj is SubTextMessageModel {
                    let textModel = obj as! SubTextMessageModel
                    if textModel.msg != nil && textModel.msg == msg {
                        textModel.status = .Failed
                        self.delegate?.chatDataSourceDidUpdate(self)
                        return
                    }
                }
            }
        }
        
        // message successfully sent, find that msg and change status to Success
        OneMessage.sharedInstance.didSendMessageBlock = { (msg: XMPPMessage)-> Void in
            let count = self.messages.count
            for var i = count-1; i >= 0; i-- {
                let obj = self.messages[i]
                if obj is SubTextMessageModel {
                    let textModel = obj as! SubTextMessageModel
                    if textModel.msg != nil && textModel.msg == msg {
                        textModel.status = .Success
                        self.delegate?.chatDataSourceDidUpdate(self)
                        return
                    }
                }
            }
        }
    }
    
    // load archived messages from database as chat history
    func loadArchivedMessages() {
        if let _ = recipient {
            let jid = recipient!.jidStr
            let results = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient!.jidStr)
            
            for message in results! {
                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(XMLString: message.messageStr)
                } catch _ {
                    element = nil
                }
                
                let body: String
                let sender: String
                let date: NSDate
                
                date = message.timestamp
                
                if message.body() != nil {
                    body = message.body()
                } else {
                    body = ""
                }
                var inComing = false
                if element.attributeStringValueForName("to") == jid {
                    let displayName = OneChat.sharedInstance.xmppStream?.myJID
                    sender = displayName!.bare()
                    inComing = false
                } else {
                    sender = jid
                    inComing = true
                }
                if let type = element.attributeStringValueForName("type") {
                    if type == "chat" {
                        let msg = createTextMessageModel(String(self.nextMessageId), senderId: sender, text: body, date: date, isIncoming: inComing, status: .Success)
                        self.messages.append(msg)
                    } else if type == "image" {
                        
                        let width = element.attributeFloatValueForName("width", withDefaultValue: 300)
                        let height = element.attributeFloatValueForName("height", withDefaultValue: 300)
                        let msg = createSubPhotoModel(String(self.nextMessageId), senderId: sender, image: nil, imageUrl: body, size: CGSizeMake(CGFloat(width), CGFloat(height)), date: date, isIncoming: inComing, status: .Success)
                        self.messages.append(msg)
                    }
                    self.nextMessageId++
                    self.delegate?.chatDataSourceDidUpdate(self)
                }
                
            }
        }
        
    }

    lazy var messageSender: AppMessageSender = {
        let sender = AppMessageSender()
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        return sender
    }()

    var hasMoreNext: Bool {
        return false
    }

    var hasMorePrevious: Bool {
        return false
    }

    var chatItems: [ChatItemProtocol] {
        return self.messages
    }

    weak var delegate: ChatDataSourceDelegateProtocol?

    func loadNext(completion: () -> Void) {
        
    }

    func loadPrevious(completion: () -> Void) {
        
    }

    // user send new text message
    func addTextMessage(text: String) {
        if let _ = recipient {
            
            OneMessage.sendMessage(text, to: recipient!.jidStr, completionHandler: { (stream, message) -> Void in
                
            })
            
        }
        
    }
    
    // user select photo to send as image message
    func addPhotoMessage(image: UIImage) {
        if let _ = recipient {
            // we resize first to small enough image
            let img = RBResizeImage(image, targetSize: CGSizeMake(500, 500))
            let maxWidth: CGFloat = 300
            var size: CGSize
            if img.size.width < maxWidth {
                size = img.size
            } else {
                size = CGSizeMake(maxWidth, maxWidth * img.size.height / img.size.width)
            }
            let msg = createSubPhotoModel(String(self.nextMessageId), senderId: recipient!.jidStr, image: img, imageUrl: nil, size: size, date: NSDate(), isIncoming: false, status: .Sending)
            self.messages.append(msg)
            self.nextMessageId++
            self.delegate?.chatDataSourceDidUpdate(self)
            
            // upload image to imgur service, then send image to xmpp server as link
            UploadImageService.uploadImage(img, completion: { (imageUrl, error) -> Void in
                if let _ = imageUrl {
                    msg.status = .Success
                    OneMessage.sendImage(imageUrl!.link, to: self.recipient!.jidStr, width: imageUrl!.width, height: imageUrl!.height)
                } else {
                    // error happens
                    msg.status = .Failed
                }
                self.delegate?.chatDataSourceDidUpdate(self)
            })
            
        }
    }
    
    func receiveTextMessage(text: String, from: String) {
        let msg = createTextMessageModel(String(self.nextMessageId), senderId: from, text: text, date: NSDate(), isIncoming: true, status: .Success)
        self.messages.append(msg)
        self.nextMessageId++
        self.delegate?.chatDataSourceDidUpdate(self)
    }

    func receiveImageMessage(link: String, from: String, width: CGFloat, height: CGFloat) {
        let msg = createSubPhotoModel(String(self.nextMessageId), senderId: from, image: nil, imageUrl: link, size: CGSizeMake(width, height), date: NSDate(), isIncoming: true, status: .Success)
        self.messages.append(msg)
        self.nextMessageId++
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    
    func adjustNumberOfMessages(preferredMaxCount preferredMaxCount: Int?, focusPosition: Double, completion:(didAdjust: Bool) -> Void) {
        
        completion(didAdjust: true)
    }
}
