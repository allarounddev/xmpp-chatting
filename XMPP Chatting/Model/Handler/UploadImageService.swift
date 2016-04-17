//
//  UploadImageService.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 2/29/16.
//  Copyright © 2016 tutacode. All rights reserved.
//


import Foundation
import Alamofire
import UIKit
import SwiftyJSON

class ImageObject {
    var link = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    init(link: String, width: CGFloat, height: CGFloat) {
        self.link = link
        self.width = width
        self.height = height
    }
}

// upload image to imgur server, then use image url to send as image message
class UploadImageService {
    
    struct Constants {
        static let baseUrl = "https://api.imgur.com/3/image"
    }
    
    static let sharedInstance: UploadImageService = {
        return UploadImageService()
    }()
    
    let manager: Manager!
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var headers = Manager.defaultHTTPHeaders
        headers["Authorization"] = "Client-ID 23ca3434007adbe"
        configuration.HTTPAdditionalHeaders = headers
        manager = Manager(configuration: configuration, serverTrustPolicyManager: nil)
    }
    
    class func uploadImage(image: UIImage, completion:(imageUrl: ImageObject?, error: NSError?)->Void) {
        let manager = UploadImageService.sharedInstance.manager
        manager.upload(.POST, Constants.baseUrl, multipartFormData: { (part) -> Void in
            if let data = UIImagePNGRepresentation(image) {
                part.appendBodyPart(data: data, name: "image", fileName: "image.png", mimeType: "png")
            }
        }) { (encodingResult) -> Void in
            switch encodingResult {
            case .Success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    if let data = response.data {
                        let json = JSON(data: data)
                        if let link = json["data"]["link"].string {
                            let width = json["data"]["width"].intValue
                            let height = json["data"]["width"].intValue
                            let obj = ImageObject(link: link, width: CGFloat(width), height: CGFloat(height))
                            completion(imageUrl: obj, error: nil)
                        } else {
                            completion(imageUrl: nil, error: UploadImageService.uploadError())
                        }
                    } else {
                        completion(imageUrl: nil, error: UploadImageService.uploadError())
                    }
                }
            case .Failure(let encodingError):
                print(encodingError)
                completion(imageUrl: nil, error: UploadImageService.uploadError())
            }
        }
    }
    
    class func uploadError()-> NSError {
        return NSError(domain: "UploadService", code: 0, userInfo: [NSLocalizedDescriptionKey: "upload service error"])
    }
}