//
//  HisTrajectoryViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/10.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class HisTrajectoryViewController: UIViewController,MAMapViewDelegate,AMapSearchDelegate,FSCalendarDelegate {
    var mapView: MAMapView!
    var dateBut,leftBut,rightBut: UIButton!
    var date: Date!
    var formatter: DateFormatter!
    var caledar: FSCalendar!
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
    }
    
    func createUI()  {
        AMapServices.shared().enableHTTPS = true
        mapView = MAMapView(frame: view.bounds)
        mapView.showsCompass = false
        mapView.delegate = self
        view.addSubview(mapView)
        
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
        caledar.selectedDate = date
        caledar.isHidden = true
        caledar.delegate = self
        view.addSubview(caledar)

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
    
    func tapDateBut(sender: UIButton) {
        switch sender.tag {
        case 1001:
            self.date = Date(timeInterval: (24*60*60) * -1, since: self.date)
            self.dateBut.setTitle(checkDate(date: self.date), for: .normal)
            dateBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopright, space: 6)
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
    
    func calendar(_ calendar: FSCalendar!, didSelect date: Date!) {
        self.date = date;
        self.dateBut.setTitle(checkDate(date: self.date), for: .normal)
        dateBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopright, space: 6)
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
