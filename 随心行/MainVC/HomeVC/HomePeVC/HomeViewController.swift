//
//  HomeViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/2.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,MAMapViewDelegate {
    var mapView: MAMapView!
    var indexView: UIImageView!
    var indexShow: Bool = false
    var deviSelView: DeviceView!
    var deviceArr: NSMutableArray = []
    var user : UserInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeMethod()
    }
    
    func initializeMethod() {
        user = UnarchiveUser()
//        if user != nil {
//           deviceArr.add([""])
//        }
//        deviceArr.add(user)
       let devices = FMDbase.shared().selectUsers(userid: user.userId!)!
        for  i in 0...(devices.count - 1) {
            let userItem: UserInfo = devices[i] as! UserInfo
            let dic: NSMutableDictionary = NSMutableDictionary(dictionary:["DEVICEIMA": userItem.deviceIma!, "DEVICENAME": userItem.deviceName!,"DEVICESELECT":"0"])
            if userItem.userId == user.userId {
                dic.addEntries(from: ["DEVICESELECT":"1"])
            }
            deviceArr.add(dic)
            if i ==  (devices.count - 1){
                let dic: NSMutableDictionary = NSMutableDictionary(dictionary:["DEVICEIMA": String(describing: UIImageJPEGRepresentation(#imageLiteral(resourceName: "icon_img_3"), 1)?.base64EncodedString()), "DEVICENAME": Localizeable(key: "添加设备"),"DEVICESELECT":"0"])
                deviceArr.add(dic)
                print(dic)
            }
        }
        print(deviceArr)
        if deviceArr.count > 0 {
            deviSelView.frame = CGRect(x: 10.0, y: 4.0, width: MainScreen.width - 20, height: CGFloat(deviceArr.count) * 3)
            deviSelView.deviceArr = deviceArr
            deviSelView.updateTabUI()
        }
    }
    
    func createUI() {
        title = "首页"
        view.backgroundColor = UIColor.white
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        let leftBar = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 36))
        let deviceView = UIImageView(frame: CGRect(x: 0, y: 0, width: leftBar.frame.height, height: leftBar.frame.height))
        deviceView.image = #imageLiteral(resourceName: "icon_tianjia")
        deviceView.isUserInteractionEnabled = true
        indexView = UIImageView(frame: CGRect(x: deviceView.frame.maxX + 4, y: 0, width: 10, height: 6))
        indexView.image = UIImage(named: "icon_change_1")
        indexView.center = CGPoint(x: indexView.center.x, y: leftBar.frame.height/2)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGest(tap:)))
        deviceView.addGestureRecognizer(tapGes)
        leftBar.addSubview(deviceView)
        leftBar.addSubview(indexView)
        
        let barBar = UIBarButtonItem(customView: leftBar)
        navigationItem.leftBarButtonItem = barBar
        
        deviSelView = DeviceView(frame: CGRect(x: 10, y: 4, width: MainScreen.width - 20, height: CGFloat(deviceArr.count) * 3))
        
        deviSelView.isHidden = true
        deviSelView.selectClosureWithCell { (IndexPath) in
           self.indexView.transform = CGAffineTransform.identity
           self.deviSelView.isHidden = true
           self.indexShow = !self.indexShow
        }
        view.addSubview(deviSelView)
    }
    
    func tapGest(tap: UITapGestureRecognizer) {
        indexShow = !indexShow
        if indexShow {
          deviSelView.isHidden = false
          indexView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
        }
        else{
          indexView.transform = CGAffineTransform.identity
          deviSelView.isHidden = true
        }
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
