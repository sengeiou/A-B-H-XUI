//
//  LocalizeableInfo.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/6.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class LocalizeableInfo: NSObject {
    class func swiftStaticFunc(translation_key: NSString) -> NSString {
        var s = NSLocalizedString(translation_key as String, comment: "");
        var defaults = Bundle.main.preferredLocalizations.first! as NSString
        defaults = defaults.substring(to: 2) as NSString
        if defaults != "en" {
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            let languageBundle = Bundle.init(path: path!)
            s = (languageBundle?.localizedString(forKey: translation_key as String, value: "", table: nil))!;
        }
        return s as NSString
    }
}


