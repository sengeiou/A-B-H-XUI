//
//  HisTrajectoryViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/10.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class HisTrajectoryViewController: UIViewController,MAMapViewDelegate,AMapSearchDelegate,FSCalendarDelegate,FSCalendarDataSource {
    var mapView: MAMapView!
    var dateBut,leftBut,rightBut: UIButton!
    var date: Date!
    var formatter: DateFormatter!
    var caledar: FSCalendar!
    var user: UserInfo!
    var locaView: UIView!
    var locaTit,locaSub: UILabel!
    var playBut: UIButton!
    var hisTrajectorys: NSArray?
    var coords : Array<CLLocationCoordinate2D> = []
    var annotations: Array<MAAnimatedAnnotation> = []
    var movingAnnotation : MAAnimatedAnnotation!
    var polylines : Array<MAPolyline> = []
    var timeArrs: Array<String> = []
    var search: AMapSearchAPI!
    var checkSearch: Int = 0
    var starTit,endTit: String!
    var currentMonth: Date!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMethod() {
        date = Date()
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        user = UnarchiveUser()
        requestMonthHistoryDays(monDate: date)
    }
    
    func createUI()  {
        title = Localizeable(key: "历史足迹") as String
        AMapServices.shared().enableHTTPS = true
        mapView = MAMapView(frame: CGRect(x: 0, y: 50, width: MainScreen.width, height: MainScreen.height - 50 - 80))
        print(mapView.frame ,MainScreen.height)
        mapView.showsCompass = false
        mapView.delegate = self
        view.addSubview(mapView)
        search = AMapSearchAPI()
        search.delegate = self
        
        let dateView = UIView(frame: CGRect(x: 0, y: 0, width: MainScreen.width, height: 50))
        dateView.backgroundColor = UIColor.white
        view.addSubview(dateView)
        
        leftBut = UIButton(type: .custom)
        leftBut.frame = CGRect(x: 10, y: 0, width: 70, height: 30)
        leftBut.setTitle(Localizeable(key: "前一天") as String, for: .normal)
        leftBut.setTitleColor(ColorFromRGB(rgbValue: 0x59AAFD), for: .normal)
        leftBut.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        leftBut.layer.masksToBounds = true
        leftBut.layer.cornerRadius = 3
        leftBut.layer.borderColor = ColorFromRGB(rgbValue: 0x59AAFD).cgColor
        leftBut.layer.borderWidth = 1.0
        leftBut.tag = 1001
        leftBut.addTarget(self, action: #selector(tapDateBut(sender:)), for: .touchUpInside)
        dateView.addSubview(leftBut)
        leftBut.center = CGPoint(x: leftBut.center.x, y: dateView.frame.height/2.0)
        
        rightBut = UIButton(type: .custom)
        rightBut.frame = CGRect(x: MainScreen.width - 10 - 70, y: 0, width: 70, height: 30)
        rightBut.setTitle(Localizeable(key: "后一天") as String, for: .normal)
        rightBut.setTitleColor(ColorFromRGB(rgbValue: 0x59AAFD), for: .normal)
        rightBut.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        rightBut.layer.masksToBounds = true
        rightBut.layer.cornerRadius = 3
        rightBut.layer.borderColor = ColorFromRGB(rgbValue: 0x59AAFD).cgColor
        rightBut.layer.borderWidth = 1.0
        rightBut.tag = 1002
        dateView.addSubview(rightBut)
        rightBut.addTarget(self, action: #selector(tapDateBut(sender:)), for: .touchUpInside)
        rightBut.center = CGPoint(x: rightBut.center.x, y: dateView.frame.height/2.0)
        
        dateBut = UIButton(type: .custom)
        dateBut.frame = CGRect(x: leftBut.frame.maxX + 4, y: 0, width: MainScreen.width - 28 - leftBut.frame.width * 2, height: 30)
        dateBut.setTitle(checkDate(date: date), for: .normal)
        dateBut.setTitleColor(ColorFromRGB(rgbValue: 0x59AAFD), for: .normal)
        dateBut.setImage(#imageLiteral(resourceName: "icon_change"), for: .normal)
        dateBut.setImage(#imageLiteral(resourceName: "icon_change_sel"), for: .selected)
        dateBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopright, space: 6)
        dateBut.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        dateBut.tag = 1003
        dateView.addSubview(dateBut)
        dateBut.addTarget(self, action: #selector(tapDateBut(sender:)), for: .touchUpInside)
        dateBut.center = CGPoint(x: dateBut.center.x, y: dateView.frame.height/2.0)
        
        caledar = FSCalendar(frame: CGRect(x: 0, y: dateView.frame.height + 1, width: MainScreen.width, height: 200))
        caledar.backgroundColor = UIColor.white
        caledar.autoAdjustTitleSize = false;
        caledar.setTodayColor(UIColor.clear)
        caledar.setTitleTodayColor(UIColor.black)
        caledar.setWeekdayTextColor(UIColor.black)
        caledar.setEventColor(UIColor.red)
        caledar.selectedDate = date
        caledar.isHidden = true
        caledar.delegate = self
        caledar.dataSource = self
        view.addSubview(caledar)
        
        locaView = UIView(frame: CGRect(x: 0, y: MainScreen.height - 64 - 80, width: MainScreen.width, height: 80))
        locaView.backgroundColor = UIColor.white
        view.addSubview(locaView)
        
        playBut = UIButton(type: .custom)
        playBut.frame = CGRect(x: locaView.frame.width - 126, y: 8, width: 110, height: 40)
        playBut.backgroundColor = ColorFromRGB(rgbValue: 0x59AAFD)
        playBut.setTitle(Localizeable(key: "播放轨迹") as String, for: .normal)
        playBut.layer.masksToBounds = true
        playBut.layer.cornerRadius = playBut.frame.height/2
        playBut.addTarget(self, action: #selector(tapPlayBut(sender:)), for: .touchUpInside)
        locaView.addSubview(playBut)
        
        locaTit = UILabel(frame: CGRect(x: 10, y: 4, width: MainScreen.width - playBut.frame.width - 38, height: 46))
        locaTit.text = "暂无数据"
        //        locaTit.backgroundColor = UIColor.green
        locaTit.numberOfLines = 0;
        locaTit.font = UIFont.systemFont(ofSize: 19)
        locaView.addSubview(locaTit)
        
        locaSub = UILabel(frame: CGRect(x: 10, y: locaTit.frame.maxY , width: MainScreen.width - playBut.frame.width - 38, height: 40 - 8 - 8))
        locaSub.text = "暂无数据"
        locaSub.font = UIFont.systemFont(ofSize: 13)
        locaSub.textColor = UIColor.gray
        locaView.addSubview(locaSub)
        //        locaSub.backgroundColor = UIColor.green
    }
    
    func requestMonthHistoryDays(monDate: Date) {
        MBProgressHUD.showMessage(Localizeable(key: "数据请求中...") as String!)
        let timeZone = NSTimeZone.default
        let interval = timeZone.secondsFromGMT()
        let reqDic = RequestKeyDic()
        reqDic.addEntries(from: [ "DeviceId": StrongGoString(object: user.deviceId),
                                  "TimeOffset": NSNumber(integerLiteral: interval/3600),
                                  "Time": formatter.string(from: monDate)])
        let httpMar = MyHttpSessionMar.shared
        httpMar.post(Prefix + "api/Location/MonthHistoryDays", parameters: reqDic, progress: { (Progress) in
            
        }, success: { (essionDataTask, result) in
//            MBProgressHUD.hide()
            let resultDic = result as! Dictionary<String, Any>
            let days:NSArray = resultDic["Days"] as! NSArray
            self.hisTrajectorys = days
            DispatchQueue.main.async() { () -> Void in
                self.caledar.reloadData()
                self.checkHisDaty()
            }
        }) { (SessionDataTask, error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(error.localizedDescription)
        }
    }
    
    func checkHisDaty() {
        if (hisTrajectorys != nil) {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let zone = TimeZone(secondsFromGMT: 0)
            formatter1.timeZone = zone
            var fondHis = false
            //             let dateStr = caledar.selectedDate
            for day in self.hisTrajectorys!{
                let dateStr = formatter1.date(from: day as! String)! as NSDate
                 print("dateStr \(dateStr) \n calendar \(caledar.currentMonth)")
                if (caledar.selectedDate as NSDate).fs_day == dateStr.fs_day && (caledar.selectedDate as NSDate).fs_month == dateStr.fs_month{
                    requestHistoryDay(show:false)
                    print("nowdate == ");
                    fondHis = true
                }
            }
            if !fondHis {
                MBProgressHUD.hide()
            }
        }
    }
    
    func requestHistoryDay(show: Bool) {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd"
        let zone = TimeZone(secondsFromGMT: 0)
        //        formatter1.timeZone = zone
        //        let formatter1 = DateFormatter()
        //        formatter1.dateFormat = "yyyy-MM-dd"
        //        let zone = TimeZone(secondsFromGMT: 0)
        //        //        formatter1.timeZone = zone
        //        let formatter2 = DateFormatter()
        //        formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //        print(formatter1.string(from: date))
        //        print(formatter2.date(from: String(format: "%@ 00:00:00", formatter1.string(from: date)))!)
        //        formatter2.timeZone = zone
        //        print(formatter2.date(from: String(format: "%@ 00:00:00", formatter1.string(from: date)))!.description)
        //        print(formatter2.date(from: String(format: "%@ 23:59:59", formatter1.string(from: date)))!)
        if show{
            MBProgressHUD.showMessage(Localizeable(key: "数据请求中...") as String!)
        }
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["DeviceId": StrongGoString(object: user.deviceId),
                                     "StartTime": String(format: "%@ 00:00:00", formatter1.string(from: date)),
                                     "EndTime": String(format: "%@ 23:59:59", formatter1.string(from: date)),
                                     "ShowLbs": 1,
                                     "MapType": "AMap",
                                     "SelectCount": 500])
        let httpMar = MyHttpSessionMar.shared
        print("requestDic  == \(requestDic)")
        httpMar.post(Prefix + "api/Location/History", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (essionDataTask, result) in
            MBProgressHUD.hide()
            let resultDic = result as! Dictionary<String, Any>
            print("requestHistoryDay \(resultDic)")
            let items:NSArray = resultDic["Items"] as! NSArray
            self.coords.removeAll()
            self.timeArrs.removeAll()
            for i in 0...items.count - 1{
                let locaDic:NSDictionary = items[i] as! NSDictionary
                self.coords.append(CLLocationCoordinate2D.init(latitude: Double(locaDic["Lat"] as! NSNumber), longitude: Double(locaDic["Lng"] as! NSNumber)))
                self.timeArrs.append(locaDic["Time"] as! String)
            }
            print("self.coords \(self.coords)")
//            self.drawAnnotation()
            self.checkSearch = 0
            self.checkGeocode()
        }) { (SessionDataTask, error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(error.localizedDescription)
        }
    }
    
    func checkDate(date: Date) -> String {
        var dateStr = formatter.string(from: date)
        rightBut.isEnabled = true
        rightBut.layer.borderColor = ColorFromRGB(rgbValue: 0x59AAFD).cgColor
        rightBut.setTitleColor(ColorFromRGB(rgbValue: 0x59AAFD), for: .normal)
        if dateStr == formatter.string(from: Date()) {
            dateStr = Localizeable(key: "今天") as String
            rightBut.isEnabled = false
            rightBut.layer.borderColor = UIColor.gray.cgColor
            rightBut.setTitleColor(UIColor.gray, for: .normal)
        }
        return dateStr
    }
    
    func drawAnnotation() {
        
        if dateBut.isSelected {
            dateBut.isSelected = !dateBut.isSelected
            dateBut.setImage(#imageLiteral(resourceName: "icon_change_sel"), for: .selected)
            dateBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopright, space: 6)
            caledar.isHidden = !dateBut.isSelected
        }
        
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        mapView.removeOverlays(polylines)
        polylines.removeAll()
        
        movingAnnotation = MAAnimatedAnnotation()
        movingAnnotation.coordinate = coords.first!
        annotations.append(movingAnnotation)
        
        let starAnn = MAAnimatedAnnotation()
        starAnn.coordinate = coords.first!
        starAnn.title = starTit
        annotations.append(starAnn)
        
        let endAnn = MAAnimatedAnnotation()
        endAnn.coordinate = coords.last!
        endAnn.title = endTit
        annotations.append(endAnn)
        
        mapView.addAnnotations(annotations)
        
        let polyline1:MAPolyline! =  MAPolyline.init(coordinates: &(self.coords), count: UInt(self.coords.count))
        polylines.append(polyline1)
        mapView.addOverlays(polylines)
        mapView.setVisibleMapRect(polyline1.boundingMapRect, edgePadding: UIEdgeInsetsMake(70, 50, 40, 50), animated: true)
    }
    
    func tapDateBut(sender: UIButton) {
        switch sender.tag {
        case 1001:
            self.date = Date(timeInterval: (24*60*60) * -1, since: self.date)
            self.dateBut.setTitle(checkDate(date: self.date), for: .normal)
            dateBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopright, space: 6)
            print("datadate \(self.date)  \n currentDate \(caledar.currentDate)")
            caledar.changeDate(withSelectedDate: date, currentDate: caledar.currentDate)
            break
        case 1002:
            self.date = Date(timeInterval: (24*60*60) * 1, since: self.date)
            self.dateBut.setTitle(checkDate(date: self.date), for: .normal)
            dateBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopright, space: 6)
            caledar.changeDate(withSelectedDate: date, currentDate: caledar.currentDate)
            break
        case 1003:
            sender.isSelected = !sender.isSelected
            sender.setImage(#imageLiteral(resourceName: "icon_change_sel"), for: .selected)
            dateBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopright, space: 6)
            caledar.isHidden = !sender.isSelected
            break
        default:
            break
        }
    }
    
    func tapPlayBut(sender: UIButton) {
        if(self.movingAnnotation == nil || annotations.count == 0)
        {
            return
        }
        if(self.movingAnnotation.allMoveAnimations() != nil) {
            for item in self.movingAnnotation.allMoveAnimations() {
                let animation = item
                animation.cancel()
            }
        }
        //        print(annotations)
        let movAnnView:MAPinAnnotationView = mapView .view(for: annotations.first) as! MAPinAnnotationView
        movAnnView.isHidden = false
        self.movingAnnotation.movingDirection = 0;
        self.movingAnnotation.coordinate = coords.first!
        
        
        var distances:Double = 0
        var oldPoint = MAMapPointForCoordinate(coords.first!)
        if coords.count > 1 {
            for i in 1...(coords.count - 2) {
                let distance = MAMetersBetweenMapPoints(oldPoint,MAMapPointForCoordinate(coords[i]))
                oldPoint = MAMapPointForCoordinate(coords[i])
                distances = distance + distances
            }
        }
        var duration = 0
        if coords.count > 1 {
            duration = Int(3) + Int(distances/1500)
            if duration > 10 {
                duration = 10
            }
        }
        self.movingAnnotation.addMoveAnimation(withKeyCoordinates: &(self.coords), count: UInt(self.coords.count), withDuration: CGFloat(duration), withName: nil) { (Bool) in
            if Bool{
                movAnnView.isHidden = true
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar!, didSelect date: Date!) {
        self.date = date;
        self.dateBut.setTitle(checkDate(date: self.date), for: .normal)
        dateBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopright, space: 6)
        var found = false
        print(hisTrajectorys)
        if (hisTrajectorys != nil) {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            for day in self.hisTrajectorys!{
                let dateStr = formatter1.date(from: day as! String)! as NSDate
                if (self.date as NSDate).fs_day == dateStr.fs_day && (self.date as NSDate).fs_month == dateStr.fs_month{
                    found = true
                    requestHistoryDay(show:true)
                }
            }
        }
        if !found{
            locaTit.text = "暂无数据"
            locaSub.text = "当日无定位数据"
            self.coords.removeAll()
            self.timeArrs.removeAll()
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
            mapView.removeOverlays(polylines)
            polylines.removeAll()
        }
    }
    
    func calendarCurrentMonthDidChange(_ calendar: FSCalendar!) {
        if currentMonth == nil || currentMonth != calendar.currentMonth {
            requestMonthHistoryDays(monDate: calendar.currentMonth)
            print("**currentDate \(calendar.currentMonth)")
            self.caledar.reloadData()
            currentMonth = calendar.currentMonth
        }
    }
    
    func calendar(_ calendar: FSCalendar!, hasEventFor date: Date!) -> Bool {
        var returnCall:Bool = false
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let zone = TimeZone(secondsFromGMT: 0)
        //        formatter1.timeZone = zone
        let nowDate = date! as NSDate
        if (hisTrajectorys != nil) {
            for day in self.hisTrajectorys!{
                let dateStr = formatter1.date(from: day as! String)! as NSDate
//                 print("nowDate  \(nowDate) \n dateStr \(dateStr) \n calendar \(calendar.currentMonth)")
                if nowDate.fs_day == dateStr.fs_day && nowDate.fs_month == dateStr.fs_month && nowDate.fs_month == (calendar.currentMonth as NSDate).fs_month{
                    returnCall = true
//                    print("nowDate  \(nowDate) \n dateStr \(dateStr) \n calendar \(calendar.currentMonth)")
                    break
                }
            }
        }
        return returnCall
    }
    
    func checkGeocode() {
        //        let search = AMapSearchAPI()
        //        search?.delegate = self
        let regeo0 = AMapReGeocodeSearchRequest()
        regeo0.location = AMapGeoPoint.location(withLatitude: CGFloat((coords.first?.latitude)!), longitude: CGFloat((coords.first?.longitude)!))
        regeo0.requireExtension = true
        search.aMapReGoecodeSearch(regeo0)
        
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.location(withLatitude: CGFloat((coords.last?.latitude)!), longitude: CGFloat((coords.last?.longitude)!))
        regeo.requireExtension = true
        search.aMapReGoecodeSearch(regeo)
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation.isKind(of: MAPointAnnotation.self))
        {
            let pointReuseIndetifier = "myReuseIndetifier"
            var annotationView:MAPinAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView!
            if (annotationView == nil)
            {
                annotationView =  MAPinAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView?.canShowCallout              = true
            annotationView.animatesDrop                 = false
            annotationView.isDraggable                  = false
            
            var imge =  UIImage.init(named: "userPosition")
            if (annotation as? MAAnimatedAnnotation == movingAnnotation) {
                imge  =  UIImage.init(named: "userPosition")
            }
            else{
                let imadata = NSData(base64Encoded: user.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
                var iamge: UIImage? = UIImage(data: imadata! as Data)
                if iamge == nil {
                    iamge = #imageLiteral(resourceName: "icon_img_3")
                }
                if annotation as? MAAnimatedAnnotation == annotations[1] {
                    imge = #imageLiteral(resourceName: "ic_dingwei").mergeIma(ima: iamge!.drawSquareIma(Sise: nil).drawCornerIma(Sise: nil))
                }
                if annotation as? MAAnimatedAnnotation == annotations[2] {
                    imge = #imageLiteral(resourceName: "ic_dingwei_zd").mergeIma(ima: iamge!.drawSquareIma(Sise: nil).drawCornerIma(Sise: nil))
                }
                annotationView.centerOffset = CGPoint(x: CGFloat(0), y: -CGFloat((imge?.size.height)!/2))
            }
            annotationView?.image =  imge
            
            if (annotation as? MAAnimatedAnnotation == movingAnnotation) {
                annotationView.isHidden = true
            }
            else{
                annotationView.isHidden = false
            }
            return annotationView;
        }
        return nil;
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if (overlay.isKind(of: MAPolyline.self))
        {
            let polylineRenderer = MAPolylineRenderer.init(polyline: overlay as! MAPolyline!)
            polylineRenderer?.lineWidth = 6.0
            polylineRenderer?.loadStrokeTextureImage(UIImage.init(named: "arrowTexture"))
            return polylineRenderer;
        }
        return nil;
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        locaTit.text = "暂无数据"
        locaSub.text = "当日无定位数据"
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        print(response.regeocode.addressComponent)
        checkSearch = checkSearch + 1
        if request.location.latitude == CGFloat((coords.last?.latitude)!) && request.location.longitude == CGFloat((coords.last?.longitude)!) {
            locaTit.text = response.regeocode.addressComponent.city + response.regeocode.addressComponent.district + response.regeocode.addressComponent.township
            let sessionId = timeArrs.last
//            let index = sessionId?.index((sessionId?.endIndex)!, offsetBy: -8)
//            let suffix = sessionId?.substring(from: index!)
            
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let zone = TimeZone(secondsFromGMT: 0)
            formatter1.timeZone = zone
            let date0 = formatter1.date(from: sessionId!)
            let date = getNowDateFromatAnDate(anyDate:date0!)
            formatter1.dateFormat = "HH:mm:ss"
            
            locaSub.text = formatter1.string(from: date) + " 手表精准定位"
            if locaTit.text == ""{
                locaTit.text = "暂无数据"
                locaSub.text = "当日无定位数据"
            }
            endTit = response.regeocode.formattedAddress
        }
        else{
            starTit = response.regeocode.formattedAddress
        }
        if checkSearch == 2 {
            drawAnnotation()
        }
    }
}
