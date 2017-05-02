//
//  FMDbase.swift
//  SwiftText
//
//  Created by 有限公司 深圳市 on 2017/4/10.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

import UIKit
import SQLite

class FMDbase: NSObject {
    
    var db : Connection! = nil
    
    //单例
    static let manager:FMDbase = {
        return FMDbase.init()
    }()
    class func shared() -> FMDbase {
        return manager;
    }
    
    private override init(){
        super.init()
        dbfunc()
        createDataBase()
    }
    
    public func  dbfunc() {
        do{
            let filename = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) .last! + "/SMAwatch.sqlite"
            db = try Connection(filename)
        }
        catch{
            
        }
    }
    
    func createDataBase() {
        do{
            let uerTable = Table("tb_user")
            //            let id = Expression
            try db.run(uerTable.create(temporary: false, ifNotExists: true, block: { (TableBuilder) in
                TableBuilder.column(Expression<String>("userid"))
                TableBuilder.column(Expression<String>("deviceid"))
                TableBuilder.column(Expression<String>("devicePh"))
                TableBuilder.column(Expression<String>("deviceIma"))
                TableBuilder.column(Expression<String>("relation"))
//                TableBuilder.column(Expression<String>("userName"))
//                TableBuilder.column(Expression<String>("userPass"))
//                TableBuilder.column(Expression<String>("userIma"))
            }))
          
        }catch let error as NSError{
            print(error.description)
        }
    }
    
    /*插入用户数据*/
    func insertUserInfo(userInfo : UserInfo) {
        do{
            let userTab = Table("tb_user")
            var userId = ""
            let alice = userTab.filter(Expression<String>("userid") == StrongGoString(object: userInfo.userId as AnyObject)).filter(Expression<String>("deviceid") == StrongGoString(object: userInfo.deviceId as AnyObject))
            
            for user in try db.prepare(alice){
                print("userid \(user[Expression<String>("userid")])")
                userId = user[Expression<String>("userid")]
            }
            if userId != "" {
                let update = alice.update(Expression<String>("devicePh") <- StrongGoString(object: userInfo.devicePh as AnyObject) ,Expression<String>("deviceIma") <- StrongGoString(object: userInfo.deviceIma as AnyObject),Expression<String>("relation") <- StrongGoString(object: userInfo.relatoin as AnyObject)/*,Expression<String>("userName") <- userInfo.userName!,Expression<String>("userPass") <- userInfo.userPass!,Expression<String>("userIma") <- userInfo.userIma!*/)
                let result = try db.run(update)
                print("更新用户数据 ：\(result)")
            }
            else{
                let result = userTab.insert(Expression<String>("userid") <- StrongGoString(object: userInfo.userId as AnyObject),Expression<String>("deviceid") <- StrongGoString(object: userInfo.deviceId as AnyObject),Expression<String>("devicePh") <- StrongGoString(object: userInfo.devicePh as AnyObject),Expression<String>("deviceIma") <- StrongGoString(object: userInfo.deviceIma as AnyObject),Expression<String>("relation") <- StrongGoString(object: userInfo.relatoin as AnyObject)/*,Expression<String>("userName") <- userInfo.userName!,Expression<String>("userPass") <- userInfo.userPass!,Expression<String>("userIma") <- userInfo.userIma!*/)
                let rowID = try db.run(result)
                print("插入用户数据 ：\(rowID)")
            }
        }
        catch let error as NSError{
            print("插入用户数据失败 ：\(error.description)")
        }
    }
    
    func selectUser(userid: String, deviceid: String) -> UserInfo? {
        do {
            let userTab = Table("tb_user")
            let alice = userTab.filter(Expression<String>("userid") == userid).filter(Expression<String>("deviceid") == deviceid)
            let userInfo = getNewUser()
            for user in try db.prepare(alice){
                print("userid \(user[Expression<String>("userid")])")
                userInfo.userId = user[Expression<String>("userid")]
                userInfo.deviceId = user[Expression<String>("deviceid")]
                userInfo.devicePh = user[Expression<String>("devicePh")]
                userInfo.deviceIma = user[Expression<String>("deviceIma")]
                userInfo.relatoin = user[Expression<String>("relation")]
//                userInfo.userName = user[Expression<String>("userName")]
//                userInfo.userPass = user[Expression<String>("userPass")]
//                userInfo.userIma = user[Expression<String>("userIma")]
            }
            return userInfo
        } catch  let error as NSError {
            print("查找用户数据失败 ：\(error.description)")
            return nil
        }
    }
    
    func delegateUser(userInfo : UserInfo) {
        do{
            let sql = String.init(format: "delete from tb_user where userid = \'%@\' and deviceid = \'%@\'", userInfo.userId!,userInfo.deviceId!)
           try db.execute(sql)
            print("删除用户数据")
        }catch let error as NSError{
            print("删除用户数据失败 ：\(error.description)")
        }
    }
}
