//
//  MessMode.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MessMode: NSObject {
    class func putMessRect(mess: NSAttributedString, mesRect: CGSize, dic: Dictionary<String, Any>) -> CGRect {
//        let textRect = mess.boundingRect(with: mesRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dic, context: nil)
         let textRect = mess.boundingRect(with: mesRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return textRect
    }
    
    class func componentsString(mess: String) -> String{
        var mutableStr = ""
        let strArr = mess.components(separatedBy: "\n")
        var isOne = false
        for string in strArr {
            let nesStr = NSString(string: string.replacingOccurrences(of: "", with: "&nbsp"))
            if nesStr.length == 0 && !isOne{
                isOne = true
//                mutableStr.append("<p>&nbsp</p>")
            }
            else if nesStr.length != 0{
                isOne = false
                mutableStr = mutableStr.appendingFormat("<p>%@</p>", nesStr)
            }
        }
        return mutableStr
    }
}
