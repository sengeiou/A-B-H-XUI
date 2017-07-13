//
//  AppDelegate.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/6.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
import UserNotifications

let appKey = "e6d57c4c0f27ea6234aa1fd7"
let channel = "Publish channel"
let isProduction = true

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,JPUSHRegisterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //        Defaultinfos.removeValueForKey(key: Account)
        //        Defaultinfos.putKeyWithNsobject(key: Account, value: "333")
        let account1:String? = Defaultinfos.getValueForKey(key: Account) as? String
        //        print("首次  \(account1)")
        //        if account1 != nil {
        //            print("非空 \(account1)")
        //        }
        //        else{
        //            print("空 \(account1)")
        //        }
        //        if let account = Defaultinfos.getValueForKey(key: Account){
        //            print(account)
        //        }
        //        else{
        //            print("0")
        //        }
        print(Defaultinfos.getIntValueForKey(key: FirstLun),Defaultinfos.getValueForKey(key: Account)!,account1 as Any)
        if account1 != nil{
            let homeVC = HomeViewController()
            homeVC.tabBarItem = UITabBarItem(title: "主页", image: UIImage(named: "tab_home_pre"), tag: 1001)
            let homeNav = NavViewController(rootViewController: homeVC)
            
            let messVC = MessTableViewController(nibName: "MessTableViewController", bundle: nil)
            messVC.tabBarItem = UITabBarItem(title: "消息", image: UIImage(named: "tab_messg_pre"), tag: 1002)
            let notNum = Defaultinfos.getIntValueForKey(key: warningNum)
            let applyNum = Defaultinfos.getIntValueForKey(key: applyForNum)
            let reverNum = Defaultinfos.getIntValueForKey(key: revertNum)
            messVC.tabBarItem.badgeValue = String.init(format: "%d", notNum + applyNum + reverNum)
            if notNum + applyNum + reverNum == 0{
                messVC.tabBarItem.badgeValue = nil
            }
            
            let messNav = NavViewController(rootViewController: messVC)
            
            let meVC = MeTableViewController(nibName: "MeTableViewController", bundle: nil)
            meVC.tabBarItem = UITabBarItem(title: "我的", image: #imageLiteral(resourceName: "tab_mine_pre"), tag: 1003)
            let meNav = NavViewController(rootViewController: meVC)
            
            let tabVC = UITabBarController()
            tabVC.viewControllers = [homeNav,messNav,meNav]
            window?.rootViewController = tabVC
            
            let user = UnarchiveUser()
            let httpMar = MyHttpSessionMar.shared
            let requDic = RequestKeyDic()
            
            requDic.addEntries(from: ["Name":user!.userPh!, "Pass":user!.userPass!,"LoginType":"0"])
            httpMar.post(Prefix + "api/User/Login", parameters: requDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                
            }, failure: { (URLSessionDataTask, Error) in
                
            })
        }
        else if Defaultinfos.getIntValueForKey(key: FirstLun) == 1{
            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            let nav = NavViewController(rootViewController: loginVC)
            window?.rootViewController = nav
        }
        
        if #available(iOS 10, *) {
            let entity = JPUSHRegisterEntity()
            entity.types = NSInteger(UNAuthorizationOptions.alert.rawValue) |
                NSInteger(UNAuthorizationOptions.sound.rawValue) |
                NSInteger(UNAuthorizationOptions.badge.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        } else if #available(iOS 8, *) {
            // 可以自定义 categories
            JPUSHService.register(
                forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue |
                    UIUserNotificationType.sound.rawValue |
                    UIUserNotificationType.alert.rawValue,
                categories: nil)
        } else {
            // ios 8 以前 categories 必须为nil
            JPUSHService.register(
                forRemoteNotificationTypes: UIRemoteNotificationType.badge.rawValue |
                    UIRemoteNotificationType.sound.rawValue |
                    UIRemoteNotificationType.alert.rawValue,
                categories: nil)
        }
        
        JPUSHService.setup(withOption: launchOptions, appKey: appKey, channel: channel, apsForProduction: isProduction)
        
        JPUSHService.registrationIDCompletionHandler { (int, String) in
            print("fwg== \(int), \(String)")
            //            let user = UnarchiveUser()
            //            if user != nil {
            //                JPUSHService.setTags(nil, alias: "U" + user!.userId!, callbackSelector: #selector(self.tagsUserAliasCallback(resCode:tags:alias:)), object: self)
            //            }
        }
        
        if launchOptions != nil {
            let view = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 400))
            view.backgroundColor = UIColor.gray
            view.text = launchOptions?.description
            view.numberOfLines = 0
            self.window?.addSubview(view)
        }
        
        AMapServices.shared().apiKey = "6ac033c36632fb55fa0c057059298c37"
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkDidRegister(_:)), name: NSNotification.Name.jpfNetworkDidRegister, object: nil)
        return true
    }
    
    func networkDidRegister(_ notification:Notification) {
        print("已注册")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("applicationWillTerminate")
        //        JPUSHService.setTags(nil, aliasInbackground: nil)
    }
    
    
    @objc func tagsUserAliasCallback(resCode:CInt, tags:NSSet, alias:NSString) {
        print("tagsAliasCallback \(resCode)")
        if resCode != 0 {
            JPUSHService.setTags(nil, aliasInbackground: "U" + (UnarchiveUser()?.userId)!)
        }
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo as Dictionary
        let request = response.notification.request // 收到推送的请求
        let content = request.content // 收到推送的消息内容
        
        let badge = content.badge;  // 推送消息的角标
        let body = content.body;    // 推送消息体
        let sound = content.sound;  // 推送消息的声音
        let subtitle = content.subtitle;  // 推送消息的副标题
        let title = content.title;  // 推送消息的标题
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            JPUSHService.handleRemoteNotification(userInfo)
            print("返回通知信息: \(userInfo)")
            print("iOS10 接收远程通知 \(self.logDic(dic: userInfo as NSDictionary))")
            
            guard let tabVC = self.window?.rootViewController as? UITabBarController,let type0 = userInfo["DataType"] as? String else{
                return
            }
            
            if Int(type0) == 1 {
                Defaultinfos.putKeyWithInt(key: warningNum, value: Defaultinfos.getIntValueForKey(key: warningNum) + 1)
                NotificaCenter.removeObserver(self, name: Notification.Name(rawValue: "updateSetting"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSetting"), object: nil)
            }
            if Int(type0) == 3 {
                Defaultinfos.putKeyWithInt(key: applyForNum, value: Defaultinfos.getIntValueForKey(key: applyForNum) + 1)
            }
            if Int(type0) == 999 {
                Defaultinfos.putKeyWithInt(key: revertNum, value: Defaultinfos.getIntValueForKey(key: revertNum) + 1)
            }
            
            for VC in tabVC.customizableViewControllers! {
                guard let naVC = VC as? NavViewController else {
                    break
                }
                if naVC.topViewController?.tabBarItem.tag == 1002 {
                    let notNum = Defaultinfos.getIntValueForKey(key: warningNum)
                    let applyNum = Defaultinfos.getIntValueForKey(key: applyForNum)
                    let reverNum = Defaultinfos.getIntValueForKey(key: revertNum)
                    naVC.topViewController?.tabBarItem.badgeValue = String.init(format: "%d", notNum + applyNum + reverNum)
                    if notNum + applyNum + reverNum == 0{
                        naVC.topViewController?.tabBarItem.badgeValue = nil
                    }
                }
                print ("_____  \(naVC.topViewController?.tabBarItem.tag)")
            }
            
            guard let type = userInfo["DataType"] as? String, Int(type) == 3 , let apsDic = userInfo["aps"] as? NSDictionary,let alert = apsDic["alert"] as? String,let status = userInfo["Status"] as? String   else {
                return
            }
            if Int(status) != 1 {
                let aler = UIAlertController(title: alert, message: nil, preferredStyle: .alert)
                let consentAct = UIAlertAction(title: Localizeable(key: "确定") as String, style: .default, handler: { (UIAlertAction) in
                    print("同意请求")
                    //                    let user = UnarchiveUser()
                    //                    user?.deviceId = userInfo["DeviceID"] as? String
                    //                    ArchiveRoot(userInfo: user!)
                    //                    NotificaCenter.post(name: Notification.Name(rawValue: "updateDevice"), object: self)
                    NotificaCenter.removeObserver(self, name: Notification.Name(rawValue: "updateDevice"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateDevice"), object: nil)
                })
                aler.addAction(consentAct)
                self.window?.rootViewController?.present(aler, animated: true, completion: {
                    
                })
                return
            }
            let aler = UIAlertController(title: alert, message: nil, preferredStyle: .alert)
            let refuseAct = UIAlertAction(title: Localizeable(key: "拒绝") as String, style: .default, handler: { (UIAlertAction) in
                let requDic = RequestKeyDic()
                requDic.addEntries(from: ["RequestId": userInfo["RequestID"]!,
                                          "TypeId": 2])
                MyHttpSessionMar.shared.post(Prefix + "api/AuthShare/Process", parameters: requDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    let resultDic = result as! Dictionary<String, Any>
                    if resultDic["State"] as! Int == 0{
                        
                    }
                    else{
                        MBProgressHUD.showError(resultDic["Message"] as! String)
                    }
                    
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            })
            let consentAct = UIAlertAction(title: Localizeable(key: "同意") as String, style: .default, handler: { (UIAlertAction) in
                let requDic = RequestKeyDic()
                requDic.addEntries(from: ["RequestId": userInfo["RequestID"]!,
                                          "TypeId": 1])
                MyHttpSessionMar.shared.post(Prefix + "api/AuthShare/Process", parameters: requDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    let resultDic = result as! Dictionary<String, Any>
                    if resultDic["State"] as! Int == 0{
                        
                    }
                    else{
                        MBProgressHUD.showError(resultDic["Message"] as! String)
                    }
                    
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            })
            aler.addAction(refuseAct)
            aler.addAction(consentAct)
            self.window?.rootViewController?.present(aler, animated: true, completion: {
                
            })
        }
        else{
            print(String.init(format: "iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}", body,title,subtitle,badge!,sound!,userInfo))
        }
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo as Dictionary
        let request = notification.request // 收到推送的请求
        let content = request.content // 收到推送的消息内容
        
        let badge = content.badge;  // 推送消息的角标
        let body = content.body;    // 推送消息体
        let sound = content.sound;  // 推送消息的声音
        let subtitle = content.subtitle;  // 推送消息的副标题
        let title = content.title;  // 推送消息的标题
        
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            JPUSHService.handleRemoteNotification(userInfo)
            
            print("返回通知信息: \(userInfo)  )))")
            print("iOS10 前台收到远程通知 \(self.logDic(dic: userInfo as NSDictionary))")
            guard let tabVC = self.window?.rootViewController as? UITabBarController,let type0 = userInfo["DataType"] as? String else{
                return
            }
            
            if Int(type0) == 1 {
                Defaultinfos.putKeyWithInt(key: warningNum, value: Defaultinfos.getIntValueForKey(key: warningNum) + 1)
                NotificaCenter.removeObserver(self, name: Notification.Name(rawValue: "updateSetting"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSetting"), object: nil)
            }
            if Int(type0) == 3 {
                Defaultinfos.putKeyWithInt(key: applyForNum, value: Defaultinfos.getIntValueForKey(key: applyForNum) + 1)
            }
            if Int(type0) == 999 {
                Defaultinfos.putKeyWithInt(key: revertNum, value: Defaultinfos.getIntValueForKey(key: revertNum) + 1)
            }
            
            for VC in tabVC.customizableViewControllers! {
                guard let naVC = VC as? NavViewController else {
                    break
                }
                if naVC.topViewController?.tabBarItem.tag == 1002 {
                    let notNum = Defaultinfos.getIntValueForKey(key: warningNum)
                    let applyNum = Defaultinfos.getIntValueForKey(key: applyForNum)
                    let reverNum = Defaultinfos.getIntValueForKey(key: revertNum)
                    naVC.topViewController?.tabBarItem.badgeValue = String.init(format: "%d", notNum + applyNum + reverNum)
                    if notNum + applyNum + reverNum == 0{
                        naVC.topViewController?.tabBarItem.badgeValue = nil
                    }
                }
                print ("_____  \(naVC.topViewController?.tabBarItem.tag)")
            }
            guard let type = userInfo["DataType"] as? String, Int(type) == 3 , let apsDic = userInfo["aps"] as? NSDictionary,let alert = apsDic["alert"] as? String,let status = userInfo["Status"] as? String   else {
                return
            }
            if Int(status) != 1 {
                let aler = UIAlertController(title: alert, message: nil, preferredStyle: .alert)
                let consentAct = UIAlertAction(title: Localizeable(key: "确定") as String, style: .default, handler: { (UIAlertAction) in
                    print("同意请求")
                    //                    let user = UnarchiveUser()
                    //                    user?.deviceId = userInfo["DeviceID"] as? String
                    //                    ArchiveRoot(userInfo: user!)
                    //                    NotificaCenter.post(name: Notification.Name(rawValue: "updateDevice"), object: self, userInfo: nil)
                    NotificaCenter.removeObserver(self, name: Notification.Name(rawValue: "updateDevice"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateDevice"), object: nil)
                })
                aler.addAction(consentAct)
                self.window?.rootViewController?.present(aler, animated: true, completion: {
                    
                })
                return
            }
            let aler = UIAlertController(title: alert, message: nil, preferredStyle: .alert)
            let refuseAct = UIAlertAction(title: Localizeable(key: "拒绝") as String, style: .default, handler: { (UIAlertAction) in
                let requDic = RequestKeyDic()
                requDic.addEntries(from: ["RequestId": userInfo["RequestID"]!,
                                          "TypeId": 2])
                MyHttpSessionMar.shared.post(Prefix + "api/AuthShare/Process", parameters: requDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    let resultDic = result as! Dictionary<String, Any>
                    if resultDic["State"] as! Int == 0{
                        
                    }
                    else{
                        MBProgressHUD.showError(resultDic["Message"] as! String)
                    }
                    
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            })
            let consentAct = UIAlertAction(title: Localizeable(key: "同意") as String, style: .default, handler: { (UIAlertAction) in
                let requDic = RequestKeyDic()
                requDic.addEntries(from: ["RequestId": userInfo["RequestID"]!,
                                          "TypeId": 1])
                MyHttpSessionMar.shared.post(Prefix + "api/AuthShare/Process", parameters: requDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    let resultDic = result as! Dictionary<String, Any>
                    if resultDic["State"] as! Int == 0{
                        
                    }
                    else{
                        MBProgressHUD.showError(resultDic["Message"] as! String)
                    }
                    
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            })
            aler.addAction(refuseAct)
            aler.addAction(consentAct)
            self.window?.rootViewController?.present(aler, animated: true, completion: {
                
            })
        }
        else{
            print(String.init(format: "iOS10 本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}", body,title,subtitle,badge!,sound!,userInfo))
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("get the deviceToken  \(deviceToken)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DidRegisterRemoteNotification"), object: deviceToken)
        JPUSHService.registerDeviceToken(deviceToken)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did fail to register for remote notification with error ", error)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        JPUSHService.handleRemoteNotification(userInfo)
        print("iOS7及以上系统受到通知", userInfo)
        //        let view = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 430))
        //        view.backgroundColor = UIColor.yellow
        //        view.numberOfLines = 0
        //        view.text = userInfo.description
        //        view.alpha = 0.8
        //        self.window?.addSubview(view)
        
        //        NotificationCenter.default.post(name: Notification.Name(rawValue: "AddNotificationCount"), object: nil)  //把  要addnotificationcount
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        JPUSHService.showLocalNotification(atFront: notification, identifierKey: nil)
    }
    
    @available(iOS 7, *)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
    }
    
    @available(iOS 7, *)
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
    }
    
    @available(iOS 7, *)
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        
    }
    
    func logDic(dic: NSDictionary) -> String {
        if dic.count == 0 {
            return "";
        }
        let tempStr1 = dic.description.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = String.init(format: "\"%@\"", tempStr2)
        let tempData = tempStr3.data(using: String.Encoding.utf8)
        do {
            let str = try PropertyListSerialization.propertyList(from: tempData!, options: PropertyListSerialization.ReadOptions(rawValue: UInt(Int(PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves.rawValue))), format: nil)
            return str as! String
        }
        catch let error as NSError{
            return error.description
        }
    }
}

