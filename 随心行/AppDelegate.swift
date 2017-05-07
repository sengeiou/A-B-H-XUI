//
//  AppDelegate.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/6.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        Defaultinfos.removeValueForKey(key: Account)
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
            let messNav = NavViewController(rootViewController: messVC)
            
            let meVC = MeTableViewController(nibName: "MeTableViewController", bundle: nil)
            meVC.tabBarItem = UITabBarItem(title: "我的", image: #imageLiteral(resourceName: "tab_mine_pre"), tag: 1003)
            let meNav = NavViewController(rootViewController: meVC)
            
            let tabVC = UITabBarController()
            tabVC.viewControllers = [homeNav,messNav,meNav]
            window?.rootViewController = tabVC
        }
       else if Defaultinfos.getIntValueForKey(key: FirstLun) == 1{
            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            let nav = NavViewController(rootViewController: loginVC)
            window?.rootViewController = nav
        }
        
        AMapServices.shared().apiKey = "6ac033c36632fb55fa0c057059298c37"
        UIApplication.shared.statusBarStyle = .lightContent
        return true
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

