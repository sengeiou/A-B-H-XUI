//
//  BandDeviceViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/18.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class BandDeviceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
         title = Localizeable(key: "绑定手表") as String!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addSelect(_ sender: UIButton?) {
        navigationController?.pushViewController(ScanCodeViewController(), animated: true)
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
