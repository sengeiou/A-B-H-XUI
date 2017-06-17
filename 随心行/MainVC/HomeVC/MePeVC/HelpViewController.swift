//
//  HelpViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/14.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var helpWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localizeable(key: "常见问题") as String
        // Do any additional setup after loading the view.
        helpWebView.loadRequest(URLRequest(url: URL(string: "http://139.129.202.165/HealthTracker/HT_FAQ.html")!))
//        let progressLay = wlwebl
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
