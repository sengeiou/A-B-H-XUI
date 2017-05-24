//
//  UserInfo.swift
//  SwiftText
//
//  Created by 有限公司 深圳市 on 2017/4/11.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

import UIKit

class UserInfo: NSObject,NSCoding {
    var userId : String?
    var userPh : String?
    var userName : String?
    var userPass : String?
    var userIma : String?
    var deviceId : String?
    var devicePh : String?
    var deviceIma : String?
    var deviceName : String?
    var relatoin : String?

    
    required init(coder aDecoder:NSCoder) {
        self.userId = aDecoder.decodeObject(forKey: "userId") as?String
        self.userPh = aDecoder.decodeObject(forKey: "userPh") as?String
        self.userName = aDecoder.decodeObject(forKey: "userName") as?String
        self.userPass = aDecoder.decodeObject(forKey: "userPass") as?String
        self.userIma = aDecoder.decodeObject(forKey: "userIma") as?String
        self.deviceId = aDecoder.decodeObject(forKey: "deviceId") as?String
        self.devicePh = aDecoder.decodeObject(forKey: "devicePh") as?String
        self.deviceIma = aDecoder.decodeObject(forKey: "deviceIma") as?String
        self.deviceName = aDecoder.decodeObject(forKey: "deviceName") as?String
        self.relatoin = aDecoder.decodeObject(forKey: "relat oin") as?String
        super.init() //属性赋值要在 super之前,这是 swift 基本语法(可选型应该不用在 super 之前);方法在 super 之后
    }
    
    
    override init() {
     super.init()
    
    }
    
    func encode(with aCoder:NSCoder) {
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(userPh, forKey: "userPh")
        aCoder.encode(userName, forKey: "userName")
        aCoder.encode(userPass, forKey: "userPass")
        aCoder.encode(userIma, forKey: "userIma")
        aCoder.encode(deviceId, forKey: "deviceId")
        aCoder.encode(devicePh, forKey: "devicePh")
        aCoder.encode(deviceIma, forKey: "deviceIma")
        aCoder.encode(deviceName, forKey: "deviceName")
        aCoder.encode(relatoin, forKey: "relatoin")

    }
    
}
