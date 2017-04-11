//
//  NavViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/7.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController {
    
    open var leftItemHidden: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UINavigationBar.appearance() .setBackgroundImage(UIImage.ImageWithColor(color: ColorFromRGB(rgbValue: 0x389aff), size: CGSize(width: MainScreen.width, height: 64)), for: UIBarMetrics(rawValue: 0)!)
        navigationBar.isTranslucent = false  //不透明处理
        UINavigationBar.appearance().shadowImage = UIImage() //隐藏导航栏下黑线
      //改变title文字格式
        navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 20),NSForegroundColorAttributeName:UIColor.white]
      //修改BarItem 字体颜色样式
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 11)], for: UIControlState(rawValue: 0))
        leftItemHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if childViewControllers.count >= 1 {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, hidden: leftItemHidden, action:#selector(didClickBackBarIten))
        }
     super.pushViewController(viewController, animated: animated)
    }
    
    func didClickBackBarIten() {
        popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
