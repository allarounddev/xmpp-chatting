//
//  APIConstants.swift
//  XMPP Chatting
//
//  Created by victor belenko on 3/3/16.
//  Copyright © 2016 tutacode. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    static let baseUrl = "https://backend.playerbusterapi.appspot.com"
    
    static var accessToken: String?
    
    case TradeAccessToken(token: String, type: TradeAccessTokenProvider)
    case GetXMPPCredential(useId: String)
    
    var method: Alamofire.Method {
        switch self {
        case .TradeAccessToken(facebookToken: _):
            return .POST
        case .GetXMPPCredential(useId: _):
            return .POST
        }
    
    }
    
    var path: String {
        switch self {
        case .TradeAccessToken(token: _, type: _):
            return "/oauth2/access_token"
        case .GetXMPPCredential(useId: _):
            return "/_ah/api/tstone/v1/user/getXmppCreds"
        }
    }
    
    var parameters: [String: AnyObject] {
        switch self {
        case .TradeAccessToken(token: let token, type: let type):
            return ["x_access_token": token, "x_provider": type.rawValue]
        case .GetXMPPCredential(useId: let use_id):
            return ["use_id": use_id]
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        
        let URL = NSURL(string: APIRouter.baseUrl)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        let encoding = Alamofire.ParameterEncoding.URL
        
        if let token = APIRouter.accessToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return encoding.encode(mutableURLRequest, parameters: parameters).0
    }
}

enum TradeAccessTokenProvider: String {
    case Facebook = "facebook"
    case Google = "google"
    case Twitter = "twitter"
    case None = "none"
}