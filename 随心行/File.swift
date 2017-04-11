//
//  File.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/6.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
import AFNetworking

let MainScreen = UIScreen.main.bounds

let FirstLun = "FIRSTLUN"

/*请求前缀*/
let Prefix = "http://openapi.5gcity.com/"

/*请求头*/
let Head = "3A73DE89-2C32-4DD8-A8F8-B43C1FC26C17"


func Localizeable(key: NSString) ->NSString {
    return LocalizeableInfo.swiftStaticFunc(translation_key: key)
}

let NotificaCenter = NotificationCenter.default

func ColorFromRGB(rgbValue: Int) -> UIColor{
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(rgbValue & 0xFF)) / 255.0, alpha: 1.0)
}

func systLanage()->String{
    var defaults = Bundle.main.preferredLocalizations.first! as NSString
    defaults = defaults.substring(to: 2) as NSString
    return defaults as String
}

extension UIImage{
    class func ImageWithColor(color: UIColor,size: CGSize) ->UIImage{
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIBarButtonItem{
    class func backItem(target: Any?,hidden: Bool,action: Selector) -> UIBarButtonItem{
        let backbut = UIButton(type: UIButtonType(rawValue: 0)!)
        backbut.frame = CGRect(x: 0, y: 0, width: 24, height: 41)
        backbut.isHidden = hidden
        backbut.setImage(UIImage(named: "icon_return"), for: UIControlState.normal)
        backbut.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        return UIBarButtonItem(customView: backbut)
    }
}


