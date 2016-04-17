//
//  APIManager.swift
//  XMPP Chatting
//
//  Created by victor belenko on 3/3/16.
//  Copyright © 2016 tutacode. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIManager {
    
    class func requestDataForRouter(router: APIRouter, completion:(json: JSON?, error: NSError?)-> Void) {
        Alamofire.request(router).validate().responseData { (res) -> Void in
            if res.result.isSuccess {
                print(String(data: res.result.value!, encoding: NSUTF8StringEncoding))
                let objectJson = JSON(data: res.result.value!)
                completion(json: objectJson, error: nil)
            } else {
                completion(json: nil, error: res.result.error)
            }
        }
    }
    
}

