//
//  HomeViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/2.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,MAMapViewDelegate,AMapSearchDelegate {
    var mapView: MAMapView!
    var indexView: UIImageView!
    var indexShow: Bool = false
    var toolShow: Bool = true
    var isNavi: Bool = false
    var deviSelView: DeviceView?
    var deviceArr: NSMutableArray = []
    var user : UserInfo!
    var deviceView: UIImageView!
    var toolView: DeviceToolView!
    var leftBar,zoomView,locaView,building: UIView!
    var titLab: UILabel!
    var addZoom: UIButton!
    var subtractZoom,userLacaBut,deviceLacaBut, navigationBut: UIButton!
    var deviceCoor: CLLocationCoordinate2D?
    var devicePoint: MAPointAnnotation?
    var search: AMapSearchAPI!
    var buildTit,buildSub: UILabel!
    var deviceMode: Int!
    var lastCommunTime: String!
    var positionType: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.ImageWithColor(color: ColorFromRGB(rgbValue: 0x389aff), size: CGSize(width: MainScreen.width, height: 64)), for: UIBarMetrics(rawValue: 0)!)
        requestDeviceData(showProgress: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificaCenter.removeObserver(self)
    }
    
    func requestDeviceData(showProgress: Bool) {
        if showProgress{
            MBProgressHUD.showMessage(Localizeable(key: "正在查询设备...") as String!)
        }
        user = UnarchiveUser()
        let timeZone = NSTimeZone.system
        let interval = timeZone.secondsFromGMT()
        let httpMar = MyHttpSessionMar.shared
        print(user.deviceId)
        let requestDic0 = RequestKeyDic()
        //        if user?.deviceId == nil {
        //            return
        //        }
        //        requestDic0.addEntries(from: ["DeviceId": StrongGoString(object: (user?.deviceId)!)])
        //        httpMar.post(Prefix + "api/AuthShare/ShareList", parameters: requestDic0, progress: { (Progress) in
        //
        //        }, success: { (URLSessionDataTask, result) in
        //            let resultDic = result as! Dictionary<String, Any>
        //            print("resultDic \(resultDic)")
        //            let items:Array<Dictionary<String, Any>> = resultDic["Items"] as! Array<Dictionary<String, Any>>
        //            var userImaUrl = ""
        //            var foneDevice = false
        //            if resultDic["State"] as! Int == 0{
        //                for i in 0...(items.count - 1){
        //                    if self.user.userId != nil{
        //                        let itemDic = items[i]
        //                        if Int(self.user.userId!) == itemDic["UserId"] as? Int{
        //                            self.user.userId = StrongGoString(object: itemDic["UserId"]  as! Int)
        //                            self.user.userPh = StrongGoString(object: itemDic["LoginName"])
        //                            self.user.userName = StrongGoString(object: itemDic["Username"])
        //                            self.user.relatoin = StrongGoString(object: itemDic["RelationName"])
        //                            userImaUrl = StrongGoString(object: itemDic["Avatar"])
        //                            foneDevice = true
        //                        }
        //                    }
        //                    if i == (items.count - 1) && foneDevice == false{
        //                        let itemDic = items[i]
        //                        self.user.userId = StrongGoString(object: itemDic["UserId"]  as! Int)
        //                        self.user.userPh = StrongGoString(object: itemDic["LoginName"])
        //                        self.user.userName = StrongGoString(object: itemDic["Username"])
        //                        self.user.relatoin = StrongGoString(object: itemDic["RelationName"])
        //                        userImaUrl = StrongGoString(object: itemDic["Avatar"])
        //                    }
        //                }
        //            }
        //            if userImaUrl == ""{
        //                userImaUrl = "0"
        //            }
        //            downloadedFrom(url: URL(string: userImaUrl)!, callBack: { (Image)  in
        //                self.user.userIma = UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["UserId": StrongGoString(object: (self.user?.userId)!),
                                     "GroupId": "",
                                     "MapType": "",
                                     "LastTime": Date().description,
                                     "TimeOffset": NSNumber(integerLiteral: interval/3600),
                                     "Token": StrongGoString(object: Defaultinfos.getValueForKey(key: AccountToken))])
        //              print("requestDic \(requestDic) frb  \(interval)")
        httpMar.post(Prefix + "api/Device/PersonDeviceList", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            let resultDic = result as! Dictionary<String, Any>
            let items:Array<Dictionary<String, Any>> = resultDic["Items"] as! Array<Dictionary<String, Any>>
            let fmbase = FMDbase.shared()
            var foundDevi = false
            fmbase.delegateUser(userInfo: self.user)
            if (items.count > 0) {
                for i in 0...(items.count - 1){
                    let itemDic = items[i]
                    var itemUser = getNewUser()
                    if self.user.deviceId != nil{
                        if Int(self.user.deviceId!) == itemDic["Id"] as? Int{
                            itemUser = self.user
                            self.deviceMode = itemDic["Model"] as! Int
                            self.deviceCoor = CLLocationCoordinate2D(latitude: itemDic["Latitude"] as! Double, longitude: itemDic["Longitude"] as! Double)
                            self.lastCommunTime = itemDic["LastCommunication"] as! String
                            self.positionType = itemDic["PositionType"] as! Int
                            foundDevi = true
                        }
                    }
                    if !foundDevi && i == (items.count - 1){
                        let itemDic0 = items[0]
                        self.deviceMode = itemDic0["Model"] as! Int
                        self.deviceCoor = CLLocationCoordinate2D(latitude: itemDic0["Latitude"] as! Double, longitude: itemDic0["Longitude"] as! Double)
                        self.lastCommunTime = itemDic0["LastCommunication"] as! String
                        self.positionType = itemDic0["PositionType"] as! Int
                        
                        //                                itemUser.userId = self.user.userId
                        self.user.deviceId = StrongGoString(object: itemDic0["Id"] as! Int)
                        self.user.devicePh = StrongGoString(object: itemDic0["Sim"])
                        self.user.deviceName = StrongGoString(object: itemDic0["NickName"])
                        self.user.relatoin = StrongGoString(object: itemDic0["RelationName"])
                    }
                    print(itemDic)
                    itemUser.userId = self.user.userId
                    itemUser.deviceId = StrongGoString(object: itemDic["Id"] as! Int)
                    itemUser.devicePh = StrongGoString(object: itemDic["Sim"])
                    itemUser.deviceName = StrongGoString(object: itemDic["NickName"])
                    itemUser.relatoin = StrongGoString(object: itemDic["RelationName"])
                    var url = StrongGoString(object: itemDic["Avatar"])
                    if url == ""{
                        url = "0"
                    }
                    downloadedFrom(url: URL(string: url)!, callBack: { (Image) in
                        var imaData: String? = UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()
                        if imaData == nil{
                            imaData = ""
                        }
                        itemUser.deviceIma = imaData
                        
                        logUser(user: itemUser)
                        fmbase.insertUserInfo(userInfo: itemUser)
                        if Int(self.user.deviceId!) == itemDic["Id"] as? Int{
                            print("000000 \(itemUser.userPh)")
                            ArchiveRoot(userInfo: itemUser)
                        }
                        if i == (items.count - 1){
                            if !foundDevi{
                                print("111111 \(self.user.userPh)")
                                ArchiveRoot(userInfo: self.user)
                                
                            }
                            if showProgress{
                                DispatchQueue.main.async() { () -> Void in
                                    MBProgressHUD.hide()
                                    if self.deviceCoor != nil{
                                        self.mapView.setCenter(self.deviceCoor!, animated: true)
                                    }
                                }
                            }
                            DispatchQueue.main.async() { () -> Void in
                                self.initializeMethod()
                                self.addAnnotation()
                                if self.isNavi{
                                    let but = self.locaView.viewWithTag(1003) as! UIButton
                                    self.tapMapFunction(sender: but)
                                }
                            }
                        }
                    })
                }
            }
            else{
                MBProgressHUD.hide()
                if !foundDevi{
                    print("22222 \(logUser(user: self.user))")
                    ArchiveRoot(userInfo: self.user)
                }
                if showProgress{
                    DispatchQueue.main.async() { () -> Void in
                        MBProgressHUD.hide()
                        if self.deviceCoor != nil{
                            self.mapView.setCenter(self.deviceCoor!, animated: true)
                        }
                    }
                }
                DispatchQueue.main.async() { () -> Void in
                    self.initializeMethod()
                    self.addAnnotation()
                    //                            if self.isNavi{
                    //                                let but = self.locaView.viewWithTag(1003) as! UIButton
                    //                                self.tapMapFunction(sender: but)
                    //                            }
                }
            }
            //                    print("返回 \(resultDic) items \(items)")
        }, failure: { (URLSessionDataTask, Error) in
            if showProgress{
                MBProgressHUD.hide()
                MBProgressHUD.showError(Error.localizedDescription)
            }
        })
        //            })
        
        //        }) { (URLSessionDataTask, Error) in
        //            if showProgress{
        //                MBProgressHUD.hide()
        //                MBProgressHUD.showError(Error.localizedDescription)
        //            }
        //        }
    }
    
    func initializeMethod() {
        self.user = UnarchiveUser()
        let devices = FMDbase.shared().selectUsers(userid: user.userId!)!
        deviceArr.removeAllObjects()
        if devices.count > 0 {
            for  i in 0...(devices.count - 1) {
                let userItem: UserInfo = devices[i] as! UserInfo
                let dic: NSMutableDictionary = NSMutableDictionary(dictionary:["DEVIUCEID":userItem.deviceId!,"DEVICEPHONE":userItem.devicePh!,"DEVICEIMA": userItem.deviceIma!, "DEVICENAME": userItem.deviceName!, "RELATION":userItem.relatoin!,"DEVICESELECT":"0"])
                if userItem.deviceId == user.deviceId {
                    dic.addEntries(from: ["DEVICESELECT":"1"])
                    //                print("imagedata = \(userItem.deviceIma)")
                    let imadata = NSData(base64Encoded: userItem.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
                    let iamge: UIImage? = UIImage(data: imadata! as Data)
                    if iamge == nil {
                        deviceView.image = #imageLiteral(resourceName: "icon_img_3")
                    }
                    else{
                        deviceView.image = iamge
                    }
                    //self.lastCommunTime
                    var titleLab: String? = userItem.deviceName
                    if (titleLab != nil){
                        let formatter1 = DateFormatter()
                        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let zone = TimeZone(secondsFromGMT: 0)
                        formatter1.timeZone = zone
                        let date = formatter1.date(from: self.lastCommunTime)
                        titLab.attributedText = attributedString(strArr: [titleLab!,Localizeable(key: "(已连接)") as String], fontArr: [UIFont.systemFont(ofSize: 20),UIFont.systemFont(ofSize: 14)], colorArr: [UIColor.white,UIColor.white])
                        print(-((date?.timeIntervalSinceNow)!))
                        print(Int((-(date?.timeIntervalSinceNow)!))/60)
                        if Int((-(date?.timeIntervalSinceNow)!))/60 > 6 {
                            titLab.attributedText = attributedString(strArr: [titleLab!,Localizeable(key: "(未连接)") as String], fontArr: [UIFont.systemFont(ofSize: 20),UIFont.systemFont(ofSize: 14)], colorArr: [UIColor.white,UIColor.white])
                        }
                        
                        
                    }
                    else{
                        titleLab = "无设备"
                        titLab.attributedText = attributedString(strArr: [titleLab!,Localizeable(key: "(未连接)") as String], fontArr: [UIFont.systemFont(ofSize: 20),UIFont.systemFont(ofSize: 14)], colorArr: [UIColor.white,UIColor.white])
                    }
                }
                deviceArr.add(dic)
                if i ==  (devices.count - 1){
                    let imaStr = UIImageJPEGRepresentation(#imageLiteral(resourceName: "icon_tianjia"), 1)?.base64EncodedString()
                    let dic: NSMutableDictionary = NSMutableDictionary(dictionary:["DEVICEIMA": imaStr!, "DEVICENAME": Localizeable(key: "添加设备"),"DEVICESELECT":"0"])
                    deviceArr.add(dic)
                }
            }
        }
        else{
            titLab.attributedText = attributedString(strArr: [Localizeable(key: "无设备") as String!,Localizeable(key: "(未连接)") as String], fontArr: [UIFont.systemFont(ofSize: 20),UIFont.systemFont(ofSize: 14)], colorArr: [UIColor.white,UIColor.white])
        }
        
        if deviceArr.count > 0 {
            //            if deviSelView != nil{
            deviSelView?.removeFromSuperview()
            deviSelView = DeviceView(frame: CGRect(x: 10, y: 4, width: MainScreen.width - 20, height: CGFloat(deviceArr.count) * 44.0))
            deviSelView?.deviceArr = deviceArr
            deviSelView?.isHidden = !indexShow
            deviSelView?.selectClosureWithCell { (IndexPath,Dictionary) in
                if IndexPath?.row == self.deviceArr.count - 1 {
                    let banVC = BandDeviceViewController(nibName: "BandDeviceViewController", bundle: nil)
                    banVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(banVC, animated: true)
                    return
                }
                self.indexShow = !self.indexShow
                self.indexView.transform = CGAffineTransform.identity
                self.deviSelView?.isHidden = !self.indexShow
                
                self.user.deviceId = StrongGoString(object: Dictionary?["DEVIUCEID"])
                self.user.devicePh = StrongGoString(object: Dictionary?["DEVICEPHONE"])
                self.user.deviceName = StrongGoString(object: Dictionary?["DEVICENAME"])
                self.user.deviceIma = StrongGoString(object: Dictionary?["DEVICEIMA"])
                self.user.relatoin = StrongGoString(object: Dictionary?["RELATION"])
                print("33333 \(self.user.userPh)")
                ArchiveRoot(userInfo: self.user)
                for j in 0...(self.deviceArr.count - 1){
                    let dic = self.deviceArr[j] as! NSMutableDictionary
                    if dic["DEVICESELECT"] as! String == "1"{
                        dic.addEntries(from: ["DEVICESELECT":"0"])
                    }
                    if dic["DEVIUCEID"] as? String == self.user.deviceId{
                        dic.addEntries(from: ["DEVICESELECT":"1"])
                    }
                }
                self.deviSelView?.deviceArr = self.deviceArr
                self.deviSelView?.tableview.reloadData()
                let imadata = NSData(base64Encoded: self.user.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
                let iamge: UIImage? = UIImage(data: imadata! as Data)
                if iamge == nil {
                    self.deviceView.image = #imageLiteral(resourceName: "icon_img_3")
                }
                else{
                    self.deviceView.image = iamge
                }
                var titleLab: String? = self.user.deviceName
                if (titleLab != nil){
                    self.titLab.attributedText = attributedString(strArr: [titleLab!,Localizeable(key: "(已连接)") as String], fontArr: [UIFont.systemFont(ofSize: 20),UIFont.systemFont(ofSize: 14)], colorArr: [UIColor.white,UIColor.white])
                }
                else{
                    titleLab = "无设备"
                    self.titLab.attributedText = attributedString(strArr: [titleLab!,Localizeable(key: "(未连接)") as String], fontArr: [UIFont.systemFont(ofSize: 20),UIFont.systemFont(ofSize: 14)], colorArr: [UIColor.white,UIColor.white])
                }
                
            }
            view.addSubview(deviSelView!)
            //            }
            //            deviSelView?.frame = CGRect(x: 10, y: 4, width: MainScreen.width - 20, height: CGFloat(deviceArr.count) * 44.0)
            //            deviSelView?.deviceArr = deviceArr
        }
        else{
            deviSelView?.removeFromSuperview()
            deviSelView = nil
            deviceView.image = #imageLiteral(resourceName: "icon_tianjia")
        }
    }
    
    func notifiction() {
        print("接收通知")
        requestDeviceData(showProgress: true)
        NotificaCenter.removeObserver(self, name: Notification.Name(rawValue: "updateDevice"), object: nil)
    }
    
    func createUI() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.buttonWithItem(target: self, butIma: #imageLiteral(resourceName: "icon_set"), frame: CGRect(x: 0, y: 0, width: 40, height: 40), action: #selector(moreSet))
        
        NotificaCenter.addObserver(self, selector: #selector(notifiction), name: Notification.Name(rawValue: "updateDevice"), object: nil)
        
        view.backgroundColor = UIColor.white
        AMapServices.shared().enableHTTPS = true
        mapView = MAMapView(frame: view.bounds)
        mapView.showsCompass = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
        
        search = AMapSearchAPI()
        search.delegate = self
        
        leftBar = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 36))
        deviceView = UIImageView(frame: CGRect(x: 0, y: 0, width: leftBar.frame.height, height: leftBar.frame.height))
        deviceView.image = #imageLiteral(resourceName: "icon_tianjia")
        deviceView.isUserInteractionEnabled = true
        deviceView.layer.masksToBounds = true
        deviceView.layer.cornerRadius = leftBar.frame.height/2
        indexView = UIImageView(frame: CGRect(x: deviceView.frame.maxX + 4, y: 0, width: 10, height: 6))
        indexView.image = UIImage(named: "icon_change_1")
        indexView.center = CGPoint(x: indexView.center.x, y: leftBar.frame.height/2)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGest(tap:)))
        deviceView.addGestureRecognizer(tapGes)
        leftBar.addSubview(deviceView)
        leftBar.addSubview(indexView)
        
        let barBar = UIBarButtonItem(customView: leftBar)
        navigationItem.leftBarButtonItem = barBar
        
        titLab = UILabel(frame: CGRect(x: 0, y: 0, width: 154, height: 44))
        titLab.attributedText = attributedString(strArr: ["无设备",Localizeable(key: "(未连接)") as String], fontArr: [UIFont.systemFont(ofSize: 20),UIFont.systemFont(ofSize: 14)], colorArr: [UIColor.white,UIColor.white])
        titLab.textAlignment = .center
        titLab.lineBreakMode = .byTruncatingMiddle
        navigationItem.titleView = titLab
        
        toolView = DeviceToolView(frame: CGRect(x: 0, y: view.bounds.height - 64 - (tabBarController?.tabBar.frame.height)! - 180, width: MainScreen.width, height: 180))
        view.addSubview(toolView)
        toolView.tapClosureWithBut { (Int) in
            //            print("点击 \(Int)")
            switch Int{
            case 101:
                let urlStr = "tel://" + self.user.devicePh!
                if let url = URL(string: urlStr){
                    if #available(iOS 10, *){
                        UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in
                            
                        })
                    }else{
                        UIApplication.shared.openURL(url)
                    }
                }
                break
            case 102:
                if (self.deviceCoor == nil){
                    MBProgressHUD.showError(Localizeable(key: "未连接设备") as String!);
                    return
                }
                let hisVC = HisTrajectoryViewController()
                hisVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hisVC, animated: true)
                break
            case 103:
                MBProgressHUD.showMessage(Localizeable(key: "正在查询...") as String)
                
                let http = MyHttpSessionMar.shared
                var phoneOper = ""
                http.get("https://sapi.k780.com/?app=phone.get&appkey=21942&sign=377d90ff1f92c75cc21dee2d4384caaa&format=json&phone=" + self.user.devicePh!, parameters: nil, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    if let rdsdic = result as? NSDictionary, let subDic = rdsdic["result"] as? NSDictionary, let operators = subDic["operators"] as? String{
                        phoneOper = operators
                    }
                    let inta = self.phoneOperator(operStr: phoneOper)
                    let resDic = RequestKeyDic()
                    resDic.addEntries(from: ["DeviceId": self.user.deviceId!,
                                             "DeviceModel": self.deviceMode,
                                             "CmdCode": 2804,
                                             "Params": self.user.devicePh! + inta,
                                             "UserId": self.user.userId!])
                    http.post(Prefix + "api/Command/SendCommand", parameters: resDic, progress: { (Progress) in
                        
                    }, success: { (URLSessionDataTask, result) in
                        MBProgressHUD.hide()
                        let resultDic = result as! Dictionary<String, Any>
                        print(resultDic)
                        if resultDic["State"] as! Int == 0{
                            
                        }
                        else{
                            MBProgressHUD.showError(resultDic["Message"] as! String)
                        }
                    }, failure: { (URLSessionDataTask, Error) in
                        MBProgressHUD.showError(Error.localizedDescription)
                    })
                    
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.hide()
                    MBProgressHUD.showError(Error.localizedDescription)
                    //                    print("error \(Error) ")
                })
                break
            case 104:
                let addressVC = AddressBookTableViewController(nibName: "AddressBookTableViewController", bundle: nil)
                addressVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(addressVC, animated: true)
                break
            case 105:
                let securityVC = SecurityTableViewController(nibName: "SecurityTableViewController", bundle: nil)
                securityVC.hidesBottomBarWhenPushed = true
                securityVC.deviceLocation = self.deviceCoor
                self.navigationController?.pushViewController(securityVC, animated: true)
                break
            case 106:
                //                let securityVC = DeviceInfoViewController(nibName: "DeviceInfoViewController", bundle: nil)
                //                securityVC.hidesBottomBarWhenPushed = true
                //                self.navigationController?.pushViewController(securityVC, animated: true)
                MBProgressHUD.showMessage(Localizeable(key: "正在发送...") as String)
                let inta = self.phoneGreetings()
                let resDic = RequestKeyDic()
                let http = MyHttpSessionMar.shared
                resDic.addEntries(from: ["DeviceId": self.user.deviceId!,
                                         "DeviceModel": self.deviceMode,
                                         "CmdCode": 2810,
                                         "Params": self.user.userPh! + inta,
                                         "UserId": self.user.userId!])
                print(resDic)
                http.post(Prefix + "api/Command/SendCommand", parameters: resDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    MBProgressHUD.hide()
                    let resultDic = result as! Dictionary<String, Any>
                    print(resultDic)
                    if resultDic["State"] as! Int == 0{
                        
                    }
                    else{
                        MBProgressHUD.showError(resultDic["Message"] as! String)
                    }
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.showError(Error.localizedDescription)
                })
                break
            default: break
            }
        }
        
        zoomView = UIView(frame: CGRect(x: MainScreen.width - 52, y: toolView.frame.minY - 94, width: 52, height: 74))
        view.addSubview(zoomView)
        
        subtractZoom = UIButton(type: .custom)
        subtractZoom.frame = CGRect(x: 0, y: zoomView.frame.height - 36, width: 36, height: 36)
        subtractZoom.setBackgroundImage(#imageLiteral(resourceName: "icon_jianshao"), for: .normal)
        subtractZoom.addTarget(self, action: #selector(changeMapZoom(sender:)), for: .touchUpInside)
        zoomView.addSubview(subtractZoom)
        
        addZoom = UIButton(type: .custom)
        addZoom.frame = CGRect(x: 0, y: subtractZoom.frame.minY - 38, width: 36, height: 36)
        addZoom.setBackgroundImage(#imageLiteral(resourceName: "icon_fangda"), for: .normal)
        addZoom.addTarget(self, action: #selector(changeMapZoom(sender:)), for: .touchUpInside)
        zoomView.addSubview(addZoom)
        
        locaView = UIView(frame: CGRect(x: MainScreen.width - 52, y: 10, width: 52, height: 36 * 3 + 32))
        view.addSubview(locaView)
        
        userLacaBut = UIButton(type: .custom)
        userLacaBut.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        userLacaBut.setBackgroundImage(#imageLiteral(resourceName: "ic_target"), for: .normal)
        userLacaBut.tag = 1001
        userLacaBut.addTarget(self, action: #selector(tapMapFunction(sender:)), for: .touchUpInside)
        locaView.addSubview(userLacaBut)
        
        deviceLacaBut = UIButton(type: .custom)
        deviceLacaBut.frame = CGRect(x: 0, y: userLacaBut.frame.maxY + 16, width: 36, height: 36)
        deviceLacaBut.setBackgroundImage(#imageLiteral(resourceName: "ic_Location"), for: .normal)
        deviceLacaBut.tag = 1002
        deviceLacaBut.addTarget(self, action: #selector(tapMapFunction(sender:)), for: .touchUpInside)
        locaView.addSubview(deviceLacaBut)
        
        navigationBut = UIButton(type: .custom)
        navigationBut.frame = CGRect(x: 0, y: deviceLacaBut.frame.maxY + 16, width: 36, height: 36)
        navigationBut.setBackgroundImage(#imageLiteral(resourceName: "ic_daohang"), for: .normal)
        navigationBut.tag = 1003
        navigationBut.addTarget(self, action: #selector(tapMapFunction(sender:)), for: .touchUpInside)
        locaView.addSubview(navigationBut)
        
        building = UIView(frame: CGRect(x: 0, y: view.bounds.height - 64 - (tabBarController?.tabBar.frame.height)!, width: MainScreen.width, height: 90))
        building.backgroundColor = UIColor.white
        view.addSubview(building)
        
        buildTit = UILabel(frame: CGRect.init(x: 16, y: 0, width: building.frame.width - 16, height: building.frame.height/2 + 8))
        buildTit.font = UIFont.systemFont(ofSize: 18)
        buildTit.numberOfLines = 2
        building.addSubview(buildTit)
        
        buildSub = UILabel(frame: CGRect.init(x: 16, y: buildTit.frame.maxY, width: building.frame.width - 16, height: building.frame.height/2 - 8))
        buildSub.font = UIFont.systemFont(ofSize: 13)
        buildSub.textColor = UIColor.gray
        building.addSubview(buildSub)
        
        buildTit.text = Localizeable(key: "暂无信息") as String
        buildSub.text = Localizeable(key: "当日没有定位信息") as String
    }
    
    func tapGest(tap: UITapGestureRecognizer) {
        indexShow = !indexShow
        if indexShow && deviSelView != nil {
            deviSelView?.isHidden = !indexShow
            indexView.transform = CGAffineTransform(rotationAngle: .pi);
        }
        else if !indexShow && deviSelView != nil{
            indexView.transform = CGAffineTransform.identity
            deviSelView?.isHidden = !indexShow
        }
        else{
            print("无设备")
            let banVC = BandDeviceViewController(nibName: "BandDeviceViewController", bundle: nil)
            banVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(banVC, animated: true)
        }
    }
    
    func changeMapZoom(sender: UIButton) {
        if sender == subtractZoom {
            mapView.zoomLevel = mapView.zoomLevel - 1
        }
        else{
            mapView.zoomLevel = mapView.zoomLevel + 1
        }
    }
    
    func moreSet() {
        if deviceView != nil {
            let moreSetVC = MoreSetTableViewController(nibName: "MoreSetTableViewController", bundle: nil)
            moreSetVC.deviceMode = deviceMode
            navigationController?.pushViewController(moreSetVC, animated: true)
        }
    }
    
    func phoneOperator(operStr: String) -> String {
        var operatorNum = ""
        if operStr.contains("移动") {
            operatorNum = ",10086,1"
        }
        if operStr.contains("联通") {
            operatorNum = ",10010,102"
        }
        if operStr.contains("电信") {
            operatorNum = ",10001,102"
        }
        return operatorNum
    }
    
    func phoneGreetings() -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter1.string(from: Date())
        let comArrs = dateStr.components(separatedBy: " ")
        let houtArr = comArrs.last?.components(separatedBy: ":")
        if Int((houtArr?.first)!)! > 6 && Int((houtArr?.first)!)! < 12 {
            return "," + user.deviceName! + ": 早上好"
        }
        else if Int((houtArr?.first)!)! >= 12 && Int((houtArr?.first)!)! < 18 {
            return "," + user.deviceName! + ": 下午好"
        }
        else if Int((houtArr?.first)!)! >= 18 && Int((houtArr?.first)!)! < 21 {
            return "," + user.deviceName! + ": 晚上好"
        }
            //        if Int((houtArr?.first)!)! >= 21 && Int((houtArr?.first)!)! <= 6 {
        else{
            return "," + user.deviceName! + ": 晚安"
        }
    }
    
    func tapMapFunction(sender: UIButton) {
        switch sender.tag {
        case 1001:
            mapView.setCenter(mapView.userLocation.location.coordinate, animated: true)
            break
        case 1002:
            requestDeviceData(showProgress: true)
            break
        case 1003:
            if deviceCoor == nil {
                isNavi = true
                requestDeviceData(showProgress: true)
                return
            }
            isNavi = false
            let gpsVC = GPSNaviViewController()
            gpsVC.startPoint = AMapNaviPoint.location(withLatitude: CGFloat(mapView.userLocation.location.coordinate.latitude), longitude: CGFloat(mapView.userLocation.location.coordinate.longitude))
            gpsVC.endPoint = AMapNaviPoint.location(withLatitude: CGFloat((deviceCoor?.latitude)!), longitude: CGFloat((deviceCoor?.longitude)!))
            gpsVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(gpsVC, animated: true)
            break
        default:
            break
            
        }
    }
    
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        toolShow = !toolShow
        DispatchQueue.main.async() { () -> Void in
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.ImageWithColor(color: ColorFromRGB(rgbValue: 0x389aff), size: CGSize(width: MainScreen.width, height: 64)), for: UIBarMetrics(rawValue: 0)!)
        }
        UIView.animate(withDuration: 0.3, animations: {
            if !self.toolShow {
                if self.indexShow{
                    self.indexShow = false
                    self.indexView.transform = CGAffineTransform.identity
                    self.deviSelView?.isHidden = !self.indexShow
                }
                self.toolView.transform = CGAffineTransform(translationX: 0, y: self.toolView.frame.height)
                self.zoomView.transform = CGAffineTransform(translationX: 0, y: self.toolView.frame.height/1.7)
                self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: 0, y: -(self.navigationController?.navigationBar.bounds.height)!)
                self.mapView.transform = CGAffineTransform(translationX: 0, y: -(self.navigationController?.navigationBar.bounds.height)!)
            }
            else{
                self.building.transform = CGAffineTransform.identity
                self.zoomView.transform = CGAffineTransform.identity
                self.navigationController?.navigationBar.transform = CGAffineTransform.identity
                self.mapView.transform = CGAffineTransform.identity
            }
            self.leftBar.isHidden = !self.toolShow
            self.titLab.isHidden = !self.toolShow
            
        }, completion: { (Bool) in
            if !self.toolShow {
                UIView.animate(withDuration: 0.3, animations: {
                    self.building.transform = CGAffineTransform(translationX: 0, y: -self.building.frame.height)
                })
            }
            else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.toolView.transform = CGAffineTransform.identity
                })
            }
        })
    }
    
    func addAnnotation() {
        guard deviceCoor != nil else {
            return
        }
        
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.location(withLatitude: CGFloat((deviceCoor?.latitude)!), longitude: CGFloat((deviceCoor?.longitude)!))
        regeo.requireExtension = true
        search.aMapReGoecodeSearch(regeo)
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if ((annotation as? MAPointAnnotation) != devicePoint  || (annotation as? MAPointAnnotation) == nil){
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pointReuseIndetifier") as? MAPinAnnotationView
        if annotationView == nil{
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: "pointReuseIndetifier")
        }
        let imadata = NSData(base64Encoded: user.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
        var iamge: UIImage? = UIImage(data: imadata! as Data)
        if iamge == nil {
            iamge = #imageLiteral(resourceName: "icon_img_3")
        }
        let navBut = UIButton(type: .custom)
        navBut.frame = CGRect(x: 0, y: 0, width: 44, height: 60)
        navBut.setBackgroundImage(UIImage(named: "naviBackgroundNormal"), for: .normal)
        navBut.setBackgroundImage(UIImage(named: "naviBackgroundHighlighted"), for: .highlighted)
        navBut.setImage(UIImage(named: "navi"), for: .normal)
        navBut.titleLabel?.font = UIFont.systemFont(ofSize: 9)
        navBut.setTitle(Localizeable(key: "导航") as String, for: .normal)
        navBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletop, space: 4)
        navBut.addTarget(self, action: #selector(navBut(sender:)), for: .touchUpInside)
        annotationView?.leftCalloutAccessoryView = navBut
        annotationView?.image = #imageLiteral(resourceName: "ic_dingwei").mergeIma(ima: iamge!.drawSquareIma(Sise: nil).drawCornerIma(Sise: nil))
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    func navBut(sender: UIButton) {
        if deviceCoor == nil {
            isNavi = true
            requestDeviceData(showProgress: true)
            return
        }
        isNavi = false
        let gpsVC = GPSNaviViewController()
        gpsVC.startPoint = AMapNaviPoint.location(withLatitude: CGFloat(mapView.userLocation.location.coordinate.latitude), longitude: CGFloat(mapView.userLocation.location.coordinate.longitude))
        gpsVC.endPoint = AMapNaviPoint.location(withLatitude: CGFloat((deviceCoor?.latitude)!), longitude: CGFloat((deviceCoor?.longitude)!))
        gpsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(gpsVC, animated: true)
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if devicePoint != nil {
            mapView.removeAnnotation(devicePoint)
        }
        devicePoint = MAPointAnnotation()
        devicePoint?.coordinate = deviceCoor!
        devicePoint?.title = Localizeable(key: "当前位置") as String!
        mapView.addAnnotation(devicePoint)
        
        buildTit.text = Localizeable(key: "暂无信息") as String
        buildSub.text = Localizeable(key: "当日没有定位信息") as String
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        
        if devicePoint != nil {
            mapView.removeAnnotation(devicePoint)
        }
        devicePoint = MAPointAnnotation()
        devicePoint?.coordinate = deviceCoor!
        devicePoint?.title = Localizeable(key: "当前位置") as String!
        devicePoint?.subtitle = String.init(format: "%@%@%@%@",response.regeocode.addressComponent.province,response.regeocode.addressComponent.city,response.regeocode.addressComponent.district,response.regeocode.addressComponent.township)
        mapView.addAnnotation(devicePoint)
        //        buildTit.text = String.init(format: "%@%@%@%@%@%@",response.regeocode.addressComponent.province,response.regeocode.addressComponent.city,response.regeocode.addressComponent.district,response.regeocode.addressComponent.township,response.regeocode.addressComponent.neighborhood,response.regeocode.addressComponent.building)
        buildTit.text = response.regeocode.formattedAddress
        if buildTit.text == "" {
            buildTit.text = Localizeable(key: "暂无信息") as String
        }
        buildSub.text = positionType(type: positionType)
    }
    
    func positionType(type: Int) -> String {
        switch type {
        case 1:
            return Localizeable(key: "GPS 定位") as String
        case 2:
            return Localizeable(key: "LBS 定位") as String
        default:
            return Localizeable(key: "WIFI 定位") as String
        }
    }
}
