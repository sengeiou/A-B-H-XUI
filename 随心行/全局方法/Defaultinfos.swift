//
//  Defaultinfos.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
let warningNum = "warningNum"   //报警
let applyForNum = "applyForNum"  //申请
let revertNum = "revertNum"     //回复

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
    
    class func putKeyWithNsobject(key: String,value: Any) {
    let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    class func putKeyWithInt(key: String,value:Int) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
   class func getValueForKey(key: String) -> Any? {
        let defaults = UserDefaults.standard
        let result = defaults.object(forKey: key)
        return result as Any
    }
    
    class func getIntValueForKey(key:String) -> Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: key)
    }
    
    class func removeValueForKey(key:String){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
}
