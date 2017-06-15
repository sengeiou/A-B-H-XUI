//
//  AboutUsViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/14.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var aboutUsLab: UILabel!
    var aboutLab: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        aboutUsLab.sizeToFit()
        title = Localizeable(key: "关于我们") as String
        aboutLab = UILabel(frame: CGRect(x: 16, y: 20, width: MainScreen.size.width - 32, height: MainScreen.size.height - 84))
        aboutLab.text = "        北京乐普智慧医疗科技有限公司是一家专注于实现全方位家庭智慧健康管理的创新型高配科技企业。\n        在养老领域，其老年人健康监护随心行系列产品，具备一键急救，双向通话，定时定位以及跌倒预警四大核心功能，公司一直致力于建立基于云计算，互联网，物联网与大数据的智慧养老解决方案。我们坚信乐普人每次的坚持与付出，必将为老年人带来更贴心的科技成果，将让每一位老人都过上更加人性化的健康幸福生活。"
        aboutLab.numberOfLines = 0
        aboutLab.sizeToFit()
        view.addSubview(aboutLab)
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
