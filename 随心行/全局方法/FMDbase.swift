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
                TableBuilder.column(Expression<String>("deviceName"))
                TableBuilder.column(Expression<String>("relation"))
                //                TableBuilder.column(Expression<String>("userPass"))
                //                TableBuilder.column(Expression<String>("userIma"))
            }))
            
            let messAge = "create table if not exists tb_message (mes_id integer primary key autoincrement, user_id varchar(20), device_id varchar(20), date datetime,type integer,ex_type integer,message text,handle integer)"
            try db.execute(messAge)
            
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
                let update = alice.update(Expression<String>("devicePh") <- StrongGoString(object: userInfo.devicePh as AnyObject) ,Expression<String>("deviceIma") <- StrongGoString(object: userInfo.deviceIma as AnyObject),Expression<String>("relation") <- StrongGoString(object: userInfo.relatoin as AnyObject),Expression<String>("deviceName") <- StrongGoString(object: userInfo.deviceName as AnyObject)/*,Expression<String>("userPass") <- userInfo.userPass!,Expression<String>("userIma") <- userInfo.userIma!*/)
                let result = try db.run(update)
                print("更新用户数据 ：\(result)")
            }
            else{
                let result = userTab.insert(Expression<String>("userid") <- StrongGoString(object: userInfo.userId as AnyObject),Expression<String>("deviceid") <- StrongGoString(object: userInfo.deviceId as AnyObject),Expression<String>("devicePh") <- StrongGoString(object: userInfo.devicePh as AnyObject),Expression<String>("deviceIma") <- StrongGoString(object: userInfo.deviceIma as AnyObject),Expression<String>("relation") <- StrongGoString(object: userInfo.relatoin as AnyObject),Expression<String>("deviceName") <- userInfo.deviceName!/*,Expression<String>("userPass") <- userInfo.userPass!,Expression<String>("userIma") <- userInfo.userIma!*/)
                let rowID = try db.run(result)
                print("插入用户数据 ：\(rowID)")
            }
        }
        catch let error as NSError{
            print("插入用户数据失败 ：\(error.description)")
        }
    }
    
    func selectUsers(userid: String) -> NSMutableArray? {
        do {
            let devices:NSMutableArray = []
            let userTab = Table("tb_user")
            let alice = userTab.filter(Expression<String>("userid") == userid)
            for user in try db.prepare(alice){
                let userInfo = getNewUser()
                print("userid \(user[Expression<String>("userid")])")
                userInfo.userId = user[Expression<String>("userid")]
                userInfo.deviceId = user[Expression<String>("deviceid")]
                userInfo.devicePh = user[Expression<String>("devicePh")]
                userInfo.deviceIma = user[Expression<String>("deviceIma")]
                userInfo.relatoin = user[Expression<String>("relation")]
                userInfo.deviceName = user[Expression<String>("deviceName")]
                //                userInfo.userPass = user[Expression<String>("userPass")]
                //                userInfo.userIma = user[Expression<String>("userIma")]
                devices.add(userInfo)
            }
            return devices
        } catch  let error as NSError {
            print("查找用户数据失败 ：\(error.description)")
            return nil
        }
    }
    
    func selectUser(userid: String,deviceid: String) -> UserInfo? {
        do {
            //            let devices:NSMutableArray = []
            let userInfo = getNewUser()
            let userTab = Table("tb_user")
            let alice = userTab.filter(Expression<String>("userid") == userid).filter(Expression<String>("deviceid") == deviceid)
            for user in try db.prepare(alice){
                print("userid \(user[Expression<String>("userid")])")
                userInfo.userId = user[Expression<String>("userid")]
                userInfo.deviceId = user[Expression<String>("deviceid")]
                userInfo.devicePh = user[Expression<String>("devicePh")]
                userInfo.deviceIma = user[Expression<String>("deviceIma")]
                userInfo.relatoin = user[Expression<String>("relation")]
                userInfo.deviceName = user[Expression<String>("deviceName")]
                //                userInfo.userPass = user[Expression<String>("userPass")]
                //                userInfo.userIma = user[Expression<String>("userIma")]
                //                devices.add(userInfo)
            }
            return userInfo
        } catch  let error as NSError {
            print("查找用户数据失败 ：\(error.description)")
            return nil
        }
    }
    
    func delegateUser(userInfo : UserInfo) {
        do{
            //            let sql = String.init(format: "delete from tb_user where userid = \'%@\' and deviceid = \'%@\'", userInfo.userId!,userInfo.deviceId!)
            let sql = String.init(format: "delete from tb_user where userid = \'%@\'", userInfo.userId!)
            try db.execute(sql)
            print("删除用户数据")
        }catch let error as NSError{
            print("删除用户数据失败 ：\(error.description)")
        }
    }
    
    func delegateDevice(userId : String, deviceId:String) {
        do{
            let sql = String.init(format: "delete from tb_user where userid = \'%@\' and deviceid = \'%@\'", userId,deviceId)
            //            let sql = String.init(format: "delete from tb_user where userid = \'%@\'", userInfo.userId!)
            try db.execute(sql)
            print("删除用户数据")
        }catch let error as NSError{
            print("删除用户数据失败 ：\(error.description)")
        }
    }
    
    func insertMess(messDic: Dictionary<String, Any>){
        do{
            deleteMess(messDic: messDic)
            let found = selectMess(messDic: messDic)
            var sql = ""
            if !found {
                sql = String.init(format: "INSERT INTO tb_message (user_id,device_id,date,type,ex_type,message,handle) values(\'%@\',\'%@\',\'%@\',%d,%d,\'%@\',%d)", messDic["USERID"] as! String, messDic["DEVICEID"] as! String, messDic["DATE"] as! String,  Int(StrongGoString(object: messDic["TYPE"] ))!, Int(StrongGoString(object: messDic["EXTYPE"]))!, messDic["MESSAGE"] as! String,Int(StrongGoString(object: messDic["HANDLE"]))!)
            }
            else{
                sql = String.init(format: "update tb_message set type=%d, ex_type=%d, message=\'%@\', handle=%d where user_id=\'%@\' and device_id=\'%@\' and date=\'%@\'", Int(StrongGoString(object: messDic["TYPE"] ))!, Int(StrongGoString(object: messDic["EXTYPE"]))!, messDic["MESSAGE"] as! String, Int(StrongGoString(object: messDic["HANDLE"]))!,messDic["USERID"] as! String, messDic["DEVICEID"] as! String, messDic["DATE"] as! String)
            }
            try db.execute(sql)
            print("更新消息数据  \(messDic) \n \(sql)")
        }catch let error as NSError{
            print("更新消息数据失败 ：\(error.description)")
        }
    }
    
    func selectMess(messDic: Dictionary<String, Any>) -> Bool{
        var found: Bool = false
        do{
            let sql = String.init(format: "select *from tb_message where user_id=\'%@\' and device_id=\'%@\' and date=\'%@\' and type=%d and ex_type=%d",messDic["USERID"] as! String,messDic["DEVICEID"] as! String,messDic["DATE"] as! String,Int(StrongGoString(object: messDic["TYPE"] ))!,Int(StrongGoString(object: messDic["EXTYPE"]))!)
            print(sql)
            for row in try db.prepare(sql) {
                print("数据会根据查的的按顺序打印 \(row)")
                found = true
            }
            return found
        }
        catch let error as NSError{
            print("更新消息数据失败 ：\(error.description)")
            return found
        }
    }
    
    func selectMess(userid: String,deviceId: String?, messType: Int) -> NSMutableArray{
        let messArr = NSMutableArray()
        do{
            var sql = ""
            if deviceId == nil {
                sql = String.init(format: "select *from tb_message where user_id=\'%@\' and TYPE=%d order by mes_id DESC limit 1",userid,messType)
            }else{
                sql = String.init(format: "select *from tb_message where user_id=\'%@\' and device_id=\'%@\' and TYPE=%d order by mes_id DESC limit 1",userid,deviceId!,messType)
            }
            print(sql)
            for row in try db.prepare(sql) {
                print("数据会根据查的的按顺序打印 \(row)")
                messArr.add( ["USERID": StrongGoString(object: row[1]),"DEVICEID": StrongGoString(object: row[2]),"DATE": StrongGoString(object: row[3]),"TYPE": StrongGoString(object: row[4]),"EXTYPE": StrongGoString(object: row[5]),"MESSAGE": StrongGoString(object: row[6]),"HANDLE": StrongGoString(object: row[7])])
            }
            return messArr
        }
        catch let error as NSError{
            print("更新消息数据失败 ：\(error.description)")
            return messArr
        }
    }
    
    func deleteMess(messDic: Dictionary<String, Any>) {
        do{
            print("dic  __ \(messDic)")
            let sql = String.init(format: "delete from tb_message where user_id=\'%@\' and device_id=\'%@\' and date=\'%@\' and type=%d and ex_type=%d", messDic["USERID"] as! String,messDic["DEVICEID"] as! String,messDic["DATE"] as! String,Int(StrongGoString(object: messDic["TYPE"] ))!,Int(StrongGoString(object: messDic["EXTYPE"]))!)
            try db.execute(sql)
            print("删除消息数据")
        }
        catch let error as NSError{
            print("删除消息数据失败 ：\(error.description)")
        }
        
    }
}
