//
//  Message.swift
//  Chatever
//
//  Created by Wai loon Chong on 4/29/16.
//  Copyright © 2016 derrickCorp. All rights reserved.
//

import UIKit
import syncano_ios

class Message: SCDataObject {
    
    var text = ""
    var senderId = ""
    var attachment : SCFile?
    
    override class func extendedPropertiesMapping() -> [NSObject: AnyObject]{
        return ["senderId": "senderid"]
    }

}
