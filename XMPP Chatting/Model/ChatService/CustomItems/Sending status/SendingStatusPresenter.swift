//
//  SendingStatusPresenter.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 26/02/2015.
//  Copyright (c) 2016 ProcessOne. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

// This is a dirty implementation that shows what's needed to add a new type of element
// @see ChatItemsDemoDecorator

class SendingStatusModel: ChatItemProtocol {
    let uid: String
    static var chatItemType: ChatItemType {
        return "decoration-status"
    }

    var type: String { return SendingStatusModel.chatItemType }
    let status: MessageStatus

    init (uid: String, status: MessageStatus) {
        self.uid = uid
        self.status = status
    }
}

public class SendingStatusPresenterBuilder: ChatItemPresenterBuilderProtocol {

    public func canHandleChatItem(chatItem: ChatItemProtocol) -> Bool {
        return chatItem is SendingStatusModel ? true : false
    }

    public func createPresenterWithChatItem(chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return SendingStatusPresenter(
            statusModel: chatItem as! SendingStatusModel
        )
    }

    public var presenterType: ChatItemPresenterProtocol.Type {
        return SendingStatusPresenter.self
    }
}

class SendingStatusPresenter: ChatItemPresenterProtocol {

    let statusModel: SendingStatusModel
    init (statusModel: SendingStatusModel) {
        self.statusModel = statusModel
    }

    static func registerCells(collectionView: UICollectionView) {
        collectionView.registerNib(UINib(nibName: "SendingStatusCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SendingStatusCollectionViewCell")
    }

    func dequeueCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SendingStatusCollectionViewCell", forIndexPath: indexPath)
        return cell
    }

    func configureCell(cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let statusCell = cell as? SendingStatusCollectionViewCell else {
            assert(false, "expecting status cell")
            return
        }

        let attrs = [
            NSFontAttributeName : UIFont.systemFontOfSize(10.0),
            NSForegroundColorAttributeName: self.statusModel.status == .Failed ? UIColor.redColor() : UIColor.blackColor()
        ]
        statusCell.text = NSAttributedString(
            string: self.statusText(),
            attributes: attrs)
    }

    func statusText() -> String {
        switch self.statusModel.status {
        case .Failed:
            return NSLocalizedString("Sending failed", comment: "")
        case .Sending:
            return NSLocalizedString("Sending...", comment: "")
        default:
            return ""
        }
    }

    var canCalculateHeightInBackground: Bool {
        return true
    }

    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 19
    }
}
