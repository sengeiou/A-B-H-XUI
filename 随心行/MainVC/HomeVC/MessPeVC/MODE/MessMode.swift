//
//  MessMode.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MessMode: NSObject {
    class func putMessRect(mess: NSString, mesRect: CGSize, dic: Dictionary<String, Any>) -> CGRect {
        let textRect = mess.boundingRect(with: mesRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dic, context: nil)
        return textRect
    }
}
