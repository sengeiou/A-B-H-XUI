//
//  MyHttpSessionMar.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
import AFNetworking

class MyHttpSessionMar: AFHTTPSessionManager {
    static var shared: MyHttpSessionMar {
        struct Static {
            static let instance: MyHttpSessionMar = MyHttpSessionMar()
        }
        Static.instance.initialize()
        return Static.instance
    }
    
    func initialize(){
        self.requestSerializer = AFJSONRequestSerializer()
        self.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json","text/json") as? Set<String>
        self.requestSerializer.setValue("3A73DE89-2C32-4DD8-A8F8-B43C1FC26C17", forHTTPHeaderField: "key")
        self.requestSerializer.setValue("application/json", forHTTPHeaderField: "content-type")
    }
    
   class func shared1() -> MyHttpSessionMar{
        let httpMar = MyHttpSessionMar()
    
      return httpMar
    }
  
    
//        static let shared = MyHttpSessionMar()
//        private override init() {}
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

//    static let manager1:MyHttpSessionMar = {
//        return MyHttpSessionMar()
//    }()
//    class func shared1() -> MyHttpSessionMar {
//        return manager1;
//    }
    
//    private override init(){
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}

