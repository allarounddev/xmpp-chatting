//
//  UploadImageService.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 2/29/16.
//  Copyright © 2016 tutacode. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import SDWebImage
import XMPPFramework
import Alamofire

// manage current logged in user
class LoginHandler {
    
    struct Constants {
        static let facebookNameKey = "xmpp.chatting.facebookName"
        
        static let userIdKey = "xmpp.chatting.userId"
        static let passwordKey = "xmpp.chatting.password"
        
        static let updatedUserInfoKey = "xmpp.updatedUserInfo"
        
    
    }
    
    static let sharedInstance: LoginHandler = {
        return LoginHandler()
    }()
    
    var username: String? {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(self.username, forKey: Constants.facebookNameKey)
        }
        
    }
    
    var userId: String? {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(userId, forKey: Constants.userIdKey)
        }
    }
    var password: String? {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(password, forKey: Constants.passwordKey)
        }
    }
    
    func isLoggedIn()-> Bool {
        if let _ = userId {
            return true
        }
        return false
    }
    
    init() {
        userId = NSUserDefaults.standardUserDefaults().objectForKey(Constants.userIdKey) as? String
        password = NSUserDefaults.standardUserDefaults().objectForKey(Constants.passwordKey) as? String
//        userId = "tester3@xmpp.pb.pathoz.com"
//        password = "123456"
    }
    
    // after login by social network, we have auth token, then trade with api server
    func startSignInWithSocialProvider(provider: TradeAccessTokenProvider, token: String, completion: (success: Bool, error: NSError?)->Void) {
        let router = APIRouter.TradeAccessToken(token: token, type: provider)
        APIManager.requestDataForRouter(router) { (json, error) -> Void in
            if let json = json {
                if let accessToken = json["access_token"].string {
                    APIRouter.accessToken = accessToken
                    self.getXMPPCredential(json["use_id"].stringValue, completion: completion)
                } else {
                    let mError = NSError(domain: "API Errors", code: 0, userInfo: [NSLocalizedDescriptionKey: "Authentication error"])
                    completion(success: false, error: mError)
                }
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    
    func getXMPPCredential(use_id: String, completion:(success: Bool, error: NSError?)->Void) {
        let router = APIRouter.GetXMPPCredential(useId: use_id)
        APIManager.requestDataForRouter(router) { (json, error) -> Void in
            if let json = json {
                let jid = json["jid"].string
                let pwd = json["pw"].string
                if jid != nil && pwd != nil {
                    self.userId = jid
                    self.password = pwd
                    completion(success: true, error: nil)
                } else {
                    let mError = NSError(domain: "API errors", code: 0, userInfo: [NSLocalizedDescriptionKey: "get xmpp credential failed"])
                    completion(success: false, error: mError)
                }
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    //https://graph.facebook.com//picture?type=large&return_ssl_resources=1
    func updateUserInforIfNeeded() {
        /*
        if NSUserDefaults.standardUserDefaults().boolForKey(Constants.updatedUserInfoKey) == false {
            // not yet updated
            if let fbId = NSUserDefaults.standardUserDefaults().objectForKey(Constants.passwordKey) as? String {
                let profilePic = "https://graph.facebook.com/" + fbId + "/picture?type=square&return_ssl_resources=1"
                // update avatar
                let pictureUrl = NSURL(string: profilePic)
                SDWebImageDownloader.sharedDownloader().downloadImageWithURL(pictureUrl!, options: [], progress: nil, completed: { (image, data, error, finished) -> Void in
                    if let imageData = data {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.updatedUserInfoKey)
                            if let module = OneChat.sharedInstance.xmppvCardTempModule {
                                
                                if let myVcardTemp = module.myvCardTemp {
                                    //                                        myVcardTemp.familyName = name
                                    myVcardTemp.photo = imageData
                                    module.updateMyvCardTemp(myVcardTemp)
                                } else {
                                    let vCardXML = DDXMLElement(name: "vCard", xmlns: "vcard-temp")
                                    
                                    let newCardTemp = XMPPvCardTemp(fromElement: vCardXML)
                                    //                                        newCardTemp.familyName = name
                                    
                                    newCardTemp.photo = imageData
                                    module.updateMyvCardTemp(newCardTemp)
                                }
                                
                            }
                        })
                        
                    } else {
                        print("download fb image failed")
                    }
                })
            }
        }
        */
        
    }
    
    func logout() {
        self.userId = nil
        self.password = nil
    }
}
