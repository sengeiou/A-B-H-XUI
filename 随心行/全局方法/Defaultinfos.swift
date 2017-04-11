//
//  Defaultinfos.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit


class Defaultinfos: NSObject {
 
    //类型是NSObject可用这方法创建单例
//    static let manager:Defaultinfos = {
//        return Defaultinfos.init()
//    }()
//    class func shared() -> Defaultinfos {
//        return manager;
//    }
//    
//    private override init(){
//        
//    }
    
    class func putKeyWithNsobject(key: String,value: NSObject) {
    let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    class func putKeyWithInt(key: String,value:Int) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
   class func getValueForKey(key: String) -> NSObject {
        let defaults = UserDefaults.standard
        var result = defaults.object(forKey: key)
        if (result == nil) {
            result = nil
        }
        return result as! NSObject
    }
    
    class func getIntValueForKey(key:String) -> Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: key)
    }
}
