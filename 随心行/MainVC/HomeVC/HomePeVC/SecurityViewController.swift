//
//  SecurityViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/23.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class SecurityViewController: UIViewController,MAMapViewDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet var nameFile: UITextField!
    @IBOutlet var addressLab: UILabel!
    @IBOutlet var AMapView: MAMapView!
    @IBOutlet var securityBut: UIButton!
    var devicePoint: MAPointAnnotation?
    var changeDic: NSDictionary?
    var addDeviceCen: CLLocationCoordinate2D?
    var search: AMapSearchAPI!
    var searchTab: UITableView!
    var searchBar: UISearchBar!
    var searchArr: NSMutableArray = []
    var searchBut: UIButton!
    var titLab: UILabel!
    var circle: MACircle!
    var radius: Double = 1000
    var isAddSecurity: Bool = false
    lazy var user: UserInfo = {
        let user = UnarchiveUser()
        return user!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isAddSecurity {
            addAnnotation()
        }
    }
    
    func createUI() {
        
        search = AMapSearchAPI()
        search.delegate = self
        
        AMapView.showsScale = false
        AMapView.showsCompass = false
        AMapView.isRotateEnabled = false
        AMapView.delegate = self
        AMapView.zoomLevel = 15
        securityBut.layer.masksToBounds = true
        securityBut.layer.cornerRadius = securityBut.frame.height/2
        
        searchBut = UIButton(type: .custom)
        searchBut.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        searchBut.setTitle(Localizeable(key: "搜索") as String, for: .normal)
        searchBut.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        searchBut.addTarget(self, action: #selector(addSecurity(sender:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: searchBut)
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: MainScreen.width - 120, height: 44))
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: titleView.frame.width - 10, height: 44))
        searchBar.delegate = self
        searchBar.placeholder = Localizeable(key: "搜索") as String
        titLab = UILabel(frame: CGRect(x: 0, y: 0, width: MainScreen.width - 170, height: 44))
        titLab.text = Localizeable(key: "安全区域") as String
        titLab.font = UIFont.systemFont(ofSize: 20)
        titLab.textAlignment = .center
        titLab.textColor = UIColor.white
        titleView.addSubview(searchBar)
        self.navigationItem.titleView = titLab
        
        if addDeviceCen != nil {
            isAddSecurity = true
            radius = 1000
            checkGeocode()
            
        }
        else{
            addDeviceCen = CLLocationCoordinate2D(latitude: CLLocationDegrees(changeDic?["Latitude"] as! Double), longitude: CLLocationDegrees(changeDic?["Longitude"] as! Double))
            addressLab.text = changeDic?["Description"] as? String
            nameFile.text = changeDic?["FenceName"] as? String
            radius = changeDic?["Radius"] as! Double
        }
        securityBut.setTitle(String.init(format: "半径%d米内", Int(radius)), for: .normal)
        searchTab = UITableView(frame: CGRect(x: 0, y: 0, width: MainScreen.width, height: MainScreen.height - 64))
        searchTab.dataSource = self
        searchTab.delegate = self
        searchTab.isHidden = true
        view.addSubview(searchTab)
    }
    
    func checkGeocode() {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.location(withLatitude: CGFloat((addDeviceCen?.latitude)!), longitude: CGFloat((addDeviceCen?.longitude)!))
        regeo.requireExtension = true
        search.aMapReGoecodeSearch(regeo)
    }
    
    func addAnnotation() {
        AMapView.setCenter(addDeviceCen!, animated: false)
        devicePoint = MAPointAnnotation()
        let point = AMapView.convert(addDeviceCen!, toPointTo: AMapView)
        
        devicePoint?.coordinate = addDeviceCen!
        print("piint  \(addDeviceCen) *** \(point)")
        devicePoint?.isLockedToScreen = true
        devicePoint?.lockedScreenPoint = point;
        AMapView.addAnnotations([devicePoint!])
        addCircle()
    }
    
    func addCircle() {
        AMapView.remove(circle)
        circle = MACircle(center: addDeviceCen!, radius: radius)
        if radius >= 1000 {
            AMapView.zoomLevel = CGFloat(Double(15) - radius/Double(980))
        }
        else{
            AMapView.zoomLevel = CGFloat(Double(15) + radius/Double(900))
        }
        print("AMapView.zoomLevel \(AMapView.zoomLevel)")
        AMapView.add(circle)
    }
    
    func addSecurity(sender: UIButton?) {
        if sender?.titleLabel?.text == Localizeable(key: "搜索") as String {
            sender?.setTitle(Localizeable(key: "取消") as String, for: .normal)
            searchBar.becomeFirstResponder()
            self.navigationItem.titleView = searchBar
        }
        else{
            sender?.setTitle(Localizeable(key: "搜索") as String, for: .normal)
            searchBar.resignFirstResponder()
            searchTab.isHidden = true
            //            self.navigationItem.titleView?.isHidden = true
            self.navigationItem.titleView = titLab
        }
    }
    
    @IBAction func saveSelect(_ sender: UIButton?) {
        if nameFile.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入别名") as String)
            return
        }
        MBProgressHUD.showMessage(Localizeable(key: "设置中...") as String)
        let httpMgr = MyHttpSessionMar.shared
        let requestDic = RequestKeyDic()
        var postStr = ""
        if isAddSecurity {
            requestDic.setDictionary(["Item": [
                "FenceId": "",
                "DeviceId": user.deviceId!,
                "FenceName": nameFile.text!,
                "Latitude": (devicePoint?.coordinate.latitude)!,
                "Longitude": (devicePoint?.coordinate.longitude)!,
                "Radius": radius,
                "FenceType": 1,
                "AlarmType": 3,
                "IsDeviceFence": 0,
                "AlarmModel": 0,
                "DeviceFenceNo": 0,
                "Description": addressLab.text!,
                "IMEIList": [
                ],
                "Points": [
                ],
                "Address": "",
                "InUse": 1,
                "StartTime": "",
                "EndTime": ""
                ],
                "MapType": "AMap"])
            postStr = "api/Geofence/CreateGeofence"
        }
        else{
            let itemDic = NSMutableDictionary(dictionary: changeDic!)
            itemDic.addEntries(from: ["Latitude": (devicePoint?.coordinate.latitude)!,
                                      "Longitude": (devicePoint?.coordinate.longitude)!,
                                      "FenceName": nameFile.text!,
                                      "Radius": radius,
                                      "Description": addressLab.text!])
            requestDic.addEntries(from: ["Item": itemDic])
            requestDic.addEntries(from: ["MapType": "AMap"])
            print("request dic \(requestDic)")
            postStr = "api/Geofence/EditGeofence"
        }
        httpMgr.post(Prefix + postStr, parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            MBProgressHUD.hide()
            let resultDic = result as! Dictionary<String, Any>
            if resultDic["State"] as! Int == 0{
                MBProgressHUD.showSuccess(Localizeable(key: "设置成功") as String)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
            else{
                MBProgressHUD.showError(resultDic["Message"] as! String)
            }
        }, failure: { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        })
    }
    
    @IBAction func securitySelect(_ sender: UIButton?) {
        let securPickView = SecurityView(frame: CGRect(x: 0, y: 0, width: MainScreen.width, height: MainScreen.height - 64))
        let pickArr: Array<Int> = [200,500,1000,1500,2000,2500,3000,3500,4000,4500,5000]
        securPickView.pickTits = ["200米","500米","1000米","1500米","2000米","2500米","3000米","3500米","4000米","4500米","5000米"]
        let selectIndex = pickArr.index(of: Int(radius))
        securPickView.pickView.selectRow(selectIndex!, inComponent: 0, animated: false)
        
        securPickView.selectClosureWithBut { (int) in
            if int == 1001{
                self.radius = Double(pickArr[selectIndex!])
                self.addCircle()
            }
            else{
                sender?.setTitle(String.init(format: "半径%d米内", Int(self.radius)), for: .normal)
            }
        }
        securPickView.selectClosureWithPick { (Int) in
            self.radius = Double(pickArr[Int!])
            self.addCircle()
        }
        view.addSubview(securPickView)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = ""
        searchArr.removeAllObjects()
        searchTab.isHidden = false
        searchBut.setTitle(Localizeable(key: "取消") as String, for: .normal)
        searchTab.reloadData()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            let tips = AMapInputTipsSearchRequest()
            tips.keywords = searchText
            search.aMapInputTipsSearch(tips)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SEARCHCELL")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SEARCHCELL")
        }
        let tip = searchArr[indexPath.row] as! AMapTip
        cell?.textLabel?.text = tip.name
        cell?.detailTextLabel?.text = tip.address
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tip = searchArr[indexPath.row] as! AMapTip
        searchBut.setTitle(Localizeable(key: "搜索") as String, for: .normal)
        searchBar.resignFirstResponder()
        searchTab.isHidden = true
        self.navigationItem.titleView = titLab
        addressLab.text = tip.name
        
        self.addDeviceCen = CLLocationCoordinate2D(latitude: CLLocationDegrees(tip.location.latitude), longitude: CLLocationDegrees(tip.location.longitude))
        AMapView.setCenter(addDeviceCen!, animated: false)
        let point = AMapView.convert(CLLocationCoordinate2D(latitude: CLLocationDegrees(tip.location.latitude), longitude: CLLocationDegrees(tip.location.longitude)), toPointTo: AMapView)
        devicePoint?.coordinate = addDeviceCen!
        devicePoint?.isLockedToScreen = true
        devicePoint?.lockedScreenPoint = point;
    }
    
    func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        print("000000")
    }
    
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        if nameFile.isFirstResponder {
            nameFile.resignFirstResponder()
            return
        }
        let point = mapView.convert(coordinate, toPointTo: AMapView)
        self.addDeviceCen = coordinate
        devicePoint?.coordinate = addDeviceCen!
        devicePoint?.isLockedToScreen = true
        devicePoint?.lockedScreenPoint = point;
        checkGeocode()
        print("用户点击地图改变坐标 \(String(describing: addDeviceCen))")
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation as? MAPointAnnotation == nil {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pointReuseI") as? MAPinAnnotationView
        if annotationView == nil{
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: "pointReuseI")
        }
        let imadata = NSData(base64Encoded: user.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
        var iamge: UIImage? = UIImage(data: imadata! as Data)
        if iamge == nil {
            iamge = #imageLiteral(resourceName: "icon_img_3")
        }
        annotationView!.canShowCallout = true
        annotationView!.animatesDrop = true
        annotationView!.isDraggable = true
        annotationView?.image = #imageLiteral(resourceName: "ic_dingwei").mergeIma(ima: iamge!.drawCornerIma(Sise: nil))
        return annotationView
    }
    
    func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, didChange newState: MAAnnotationViewDragState, fromOldState oldState: MAAnnotationViewDragState) {
        let annotation = view as! MAPinAnnotationView
        let imadata = NSData(base64Encoded: user.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
        var iamge: UIImage? = UIImage(data: imadata! as Data)
        if iamge == nil {
            iamge = #imageLiteral(resourceName: "icon_img_3")
        }
        annotation.image = #imageLiteral(resourceName: "ic_dingwei").mergeIma(ima: iamge!.drawCornerIma(Sise: nil))
        
        print("&&&&&&&& \(newState)")
        if newState == .none {
            let point = mapView.convert(annotation.annotation.coordinate, toPointTo: AMapView)
            print("none  \(annotation.annotation.coordinate)  *** \((annotation.annotation as! MAPointAnnotation).lockedScreenPoint)  ___ \(point)")
            self.addDeviceCen = annotation.annotation.coordinate
            devicePoint?.coordinate = addDeviceCen!
            devicePoint?.isLockedToScreen = true
            devicePoint?.lockedScreenPoint = point;
            print("用户拖动大头针改变坐标 \(String(describing: addDeviceCen))")
            checkGeocode()
        }
        if newState == .starting {
            print("starting")
        }
        if newState == .dragging {
            print("dragging")
        }
        if newState == .canceling {
            print("canceling")
        }
        if newState == .ending {
            print("ending")
        }
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MACircle.self) {
            let render = MACircleRenderer.init(overlay: overlay)
            
            render?.lineWidth = 2
            render?.strokeColor = UIColor.init(colorLiteralRed: 89.0/255.0, green: 170.0/255.0, blue: 253.0/255.0, alpha: 0.8)
            render?.fillColor = UIColor.init(colorLiteralRed: 89.0/255.0, green: 170.0/255.0, blue: 253.0/255.0, alpha: 0.3)
            return render
        }
        return nil
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        print("addres \(String.init(format: "%@ - %@ -- %@ --- %@ ---- %@  +++ %@",response.regeocode.addressComponent.province,response.regeocode.addressComponent.city,response.regeocode.addressComponent.district,response.regeocode.addressComponent.township,response.regeocode.addressComponent.neighborhood,response.regeocode.addressComponent))")
        //    addressLab.text = response.regeocode.addressComponent.building
        addressLab.text = response.regeocode.formattedAddress
        if addressLab.text == "" {
            addressLab.text = Localizeable(key: "暂无信息") as String
        }
        AMapView.removeAnnotation(devicePoint)
        addAnnotation()
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            let moveCoor = mapView.convert((devicePoint?.lockedScreenPoint)!, toCoordinateFrom: mapView)
            addDeviceCen = moveCoor
            checkGeocode()
            print("用户拖动地图改变坐标 \(String(describing: addDeviceCen))")
        }
    }
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        if response.count > 0 {
            searchArr =  NSMutableArray(array: response.tips)
            searchTab.reloadData()
        }
    }
}
