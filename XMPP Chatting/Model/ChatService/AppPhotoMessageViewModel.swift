//
//  AppPhotoMessageViewModel.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 26/02/2015.
//  Copyright (c) 2016 ProcessOne. All rights reserved.
//

import Foundation
import ChattoAdditions
import SDWebImage

class AppPhotoMessageViewModel: PhotoMessageViewModel {

//    var model: SubPhotoMessageModel?
    
    override init(photoMessage: PhotoMessageModelProtocol, messageViewModel: MessageViewModelProtocol) {
        super.init(photoMessage: photoMessage, messageViewModel: messageViewModel)
        if photoMessage.isIncoming {
            self.image.value = nil
        }
        
    }

    override func willBeShown() {
        self.transferStatus.value = .Success
        if let model = photoMessage as? SubPhotoMessageModel {
            if let existed = model.existedImage {
                self.image.value = existed
            } else if let urlString = model.imageUrl {
                if let url = NSURL(string: urlString) {
                    SDWebImageDownloader.sharedDownloader().downloadImageWithURL(url, options: [], progress: { (received, total) -> Void in
                        var value = CGFloat(received) / CGFloat(total)
                        if value >= 1 {
                            value = 1
                        }
                        self.transferProgress.value = Double(value)
                    }, completed: { (image, data, error, success) -> Void in
                        self.image.value = image
                        model.existedImage = image
                    })
                }
            }
        }
    }

}

public class AppPhotoMessageViewModelBuilder: ViewModelBuilderProtocol {

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    public func createViewModel(model: SubPhotoMessageModel) -> PhotoMessageViewModel {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(model)
        let photoMessageViewModel = AppPhotoMessageViewModel(photoMessage: model, messageViewModel: messageViewModel)
        return photoMessageViewModel
    }
}
