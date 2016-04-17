//
//  FakeMessageFactory.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 26/02/2015.
//  Copyright (c) 2016 ProcessOne. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions
import XMPPFramework

class SubTextMessageModel: TextMessageModel {
    var msg: XMPPMessage?
}

func createTextMessageModel(uid: String, senderId: String,text: String, date: NSDate, isIncoming: Bool, status: MessageStatus, msg: XMPPMessage? = nil) -> SubTextMessageModel {
    let messageModel = createMessageModel(uid, senderId: senderId, isIncoming: isIncoming, type: TextMessageModel.chatItemType, date: date, status: status)
    let textMessageModel = SubTextMessageModel(messageModel: messageModel, text: text)
    textMessageModel.msg = msg
    return textMessageModel
}

func createMessageModel(uid: String, senderId: String, isIncoming: Bool, type: String, date: NSDate, status: MessageStatus) -> MessageModel {
    let messageModel = MessageModel(uid: uid, senderId: senderId, type: type, isIncoming: isIncoming, date: date, status: status)
    return messageModel
}

//func createPhotoMessageModel(uid: String, senderId: String,image: UIImage, size: CGSize, date: NSDate,isIncoming: Bool, status: MessageStatus, msg: XMPPMessage? = nil) -> PhotoMessageModel {
//    let messageModel = createMessageModel(uid, senderId: senderId, isIncoming: isIncoming, type: PhotoMessageModel.chatItemType, date: date, status: status)
//    let photoMessageModel = PhotoMessageModel(messageModel: messageModel, imageSize:size, image: image)
//    return photoMessageModel
//}

func createSubPhotoModel(uid: String, senderId: String, image: UIImage?, imageUrl: String?, size: CGSize, date: NSDate, isIncoming: Bool, status: MessageStatus, msg: XMPPMessage? = nil)-> SubPhotoMessageModel {
    let messageModel = createMessageModel(uid, senderId: senderId, isIncoming: isIncoming, type: PhotoMessageModel.chatItemType, date: date, status: status)
    let photoModel = SubPhotoMessageModel(messageModel: messageModel, url: imageUrl, imageSize: size, image: image)
    return photoModel
}


extension TextMessageModel {
    static var chatItemType: ChatItemType {
        return "text"
    }
}

extension PhotoMessageModel {
    static var chatItemType: ChatItemType {
        return "photo"
    }
}

public class SubPhotoMessageModel: PhotoMessageModelProtocol {
    public let messageModel: MessageModelProtocol
    public let image: UIImage // fixme: URL
    public var existedImage: UIImage?
    public let imageSize: CGSize
    public init(messageModel: MessageModelProtocol, url: String?, imageSize: CGSize, image: UIImage?) {
        self.messageModel = messageModel
        self.imageSize = imageSize
        self.existedImage = image
        self.imageUrl = url
        self.image = UIImage(named: "defaultPhoto")!
    }
    
    // This should be covered by DecoratedMessageModelProtocol, but compiler crashes without this (Xcode 7.1)
    public var uid: String { return self.messageModel.uid }
    var imageUrl: String?
}

extension SubPhotoMessageModel {
    static var chatItemType: ChatItemType {
        return "photo"
    }
}


