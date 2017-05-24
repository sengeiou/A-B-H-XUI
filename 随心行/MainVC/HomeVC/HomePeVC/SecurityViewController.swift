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
    }
    
    func createUI() {
        search = AMapSearchAPI()
        search.delegate = self
        
        title = Localizeable(key: "安全区域") as String
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
        
        if addDeviceCen != nil {
            checkGeocode()
        }
        
        searchTab = UITableView(frame: CGRect(x: 0, y: 0, width: MainScreen.width, height: MainScreen.height - 64))
        searchTab.dataSource = self
        searchTab.delegate = self
        searchTab.isHidden = true
        view.addSubview(searchTab)
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: MainScreen.width - 80, height: 44))
        searchBar.delegate = self
        searchBar.placeholder = Localizeable(key: "搜索") as String
        self.navigationItem.titleView = searchBar
        self.navigationItem.titleView?.isHidden = true
    }
    
    func checkGeocode() {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.location(withLatitude: CGFloat((addDeviceCen?.latitude)!), longitude: CGFloat((addDeviceCen?.longitude)!))
        regeo.requireExtension = true
        search.aMapReGoecodeSearch(regeo)
    }
    
    func addAnnotation() {
        if addDeviceCen != nil {
            AMapView.setCenter(addDeviceCen!, animated: false)
            devicePoint = MAPointAnnotation()
            let point = AMapView.convert(addDeviceCen!, toPointTo: AMapView)
             devicePoint?.coordinate = addDeviceCen!
            devicePoint?.isLockedToScreen = true
            devicePoint?.lockedScreenPoint = point;
            AMapView.addAnnotations([devicePoint!])
        }
    }
    
    func addSecurity(sender: UIButton?) {
        if sender?.titleLabel?.text == Localizeable(key: "搜索") as String {
            sender?.setTitle(Localizeable(key: "取消") as String, for: .normal)
            searchBar.becomeFirstResponder()
        }
        else{
            sender?.setTitle(Localizeable(key: "搜索") as String, for: .normal)
            searchBar.resignFirstResponder()
            searchTab.isHidden = true
            self.navigationItem.titleView?.isHidden = true
        }
    }
    
    @IBAction func saveSelect(_ sender: UIButton?) {
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = ""
        searchArr.removeAllObjects()
        searchTab.isHidden = false
        self.navigationItem.titleView?.isHidden = false
        searchBut.setTitle(Localizeable(key: "取消") as String, for: .normal)
        print("searchBarShouldBeginEditing")
        searchTab.reloadData()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange \(searchText)")
        if !searchText.isEmpty {
            let tips = AMapInputTipsSearchRequest()
            tips.keywords = searchText
            search.aMapInputTipsSearch(tips)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        print("searchBarCancelButtonClicked")
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
        self.navigationItem.titleView?.isHidden = true
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
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        
    }
    
   func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
    print("addres \(String.init(format: "%@ - %@ -- %@ --- %@ ---- %@  +++ %@",response.regeocode.addressComponent.province,response.regeocode.addressComponent.city,response.regeocode.addressComponent.district,response.regeocode.addressComponent.township,response.regeocode.addressComponent.neighborhood,response.regeocode.addressComponent))")
    addressLab.text = response.regeocode.addressComponent.building
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
