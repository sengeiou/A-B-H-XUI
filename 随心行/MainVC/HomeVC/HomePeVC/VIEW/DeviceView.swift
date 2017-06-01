//
//  DeviceView.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/2.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class DeviceView: UIView,UITableViewDelegate,UITableViewDataSource {

    typealias selectCell = (IndexPath?,NSDictionary?) -> Void
    var selectClosure: selectCell?
    var deviceArr: NSMutableArray?
    var selIndex: Int = 0
    var tableview: UITableView!
    
    
    func selectClosureWithCell(colsure: selectCell?) {
        selectClosure = colsure
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createUI()
        fatalError("init(coder:) has not been implemented")
    }
    
     func createUI() {
        backgroundColor = UIColor.white
        tableview = UITableView(frame: bounds, style: .plain)
        tableview.delegate = self
        tableview.dataSource = self
        addSubview(tableview)
        
    }
    
    func updateTabUI() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard (deviceArr != nil) else {
            return 0
        }
        return (deviceArr?.count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DEVICECELL")
        if !(cell != nil) {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "DEVICECELL")
            cell?.layer.shouldRasterize = true;
            cell?.layer.rasterizationScale = UIScreen.main.scale;
        }
        cell?.selectionStyle = .none

        let device = (deviceArr?[indexPath.row]) as! NSMutableDictionary
        let imadata = NSData(base64Encoded: device.object(forKey: "DEVICEIMA") as! String, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
        let iamge: UIImage? = UIImage(data: imadata! as Data)
        if iamge == nil {
            cell?.imageView?.image = drawImaSize(image: #imageLiteral(resourceName: "icon_img_3"), size: CGSize(width: 36, height: 36))
        }
        else{
            cell?.imageView?.image = drawImaSize(image: iamge!, size: CGSize(width: 36, height: 36))
        }
        cell?.textLabel?.text = device.object(forKey: "DEVICENAME") as? String
        if device.object(forKey: "DEVICESELECT") as? String == "1"{
            cell?.accessoryView = UIImageView(image: #imageLiteral(resourceName: "ic_Choice"))
        }
        else{
            cell?.accessoryView = nil
        }
        cell?.imageView?.layer.masksToBounds = true
        cell?.imageView?.layer.cornerRadius = (cell?.imageView?.image?.size.height)!/2
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectClosure?(indexPath,deviceArr?[indexPath.row] as? NSDictionary)
//        removeFromSuperview()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
