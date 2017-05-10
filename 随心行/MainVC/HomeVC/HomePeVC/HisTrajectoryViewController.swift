//
//  HisTrajectoryViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/10.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class HisTrajectoryViewController: UIViewController,MAMapViewDelegate,AMapSearchDelegate {
var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUI()  {
        AMapServices.shared().enableHTTPS = true
        mapView = MAMapView(frame: view.bounds)
        mapView.showsCompass = false
        mapView.delegate = self
        view.addSubview(mapView)
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
