//
//  SendingStatusCollectionViewCell.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 26/02/2015.
//  Copyright (c) 2016 ProcessOne. All rights reserved.
//

import UIKit

class SendingStatusCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var label: UILabel!

    var text: NSAttributedString? {
        didSet {
            self.label.attributedText = self.text
        }
    }
}
