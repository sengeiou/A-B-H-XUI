//
//  FamilyViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/14.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

public protocol familyDelegate:NSObjectProtocol{
    func permissionManagers()
    func delegateRelation(relationDic: NSDictionary)
}

class FamilyViewController: UIViewController {
    @IBOutlet var headIma: UIImageView!
    @IBOutlet var relationLab: UILabel!
    @IBOutlet var phoneLab: UILabel!
    @IBOutlet var permissionsLab: UILabel!
    @IBOutlet var transferBut: UIButton!
    @IBOutlet var deleteBut: UIButton!
    @IBOutlet var notTop: NSLayoutConstraint!
    var IsAdmin: Bool! = false
    var relationDic: NSDictionary!
    var delegate: familyDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUI() {
        title = StrongGoString(object: relationDic.object(forKey: "RelationName"))
        headIma.layer.masksToBounds = true
        headIma.layer.cornerRadius = headIma.frame.height/2
        print(relationDic)
        let imadata = NSData(base64Encoded: relationDic.object(forKey: "Avatar") as! String, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
        let iamge: UIImage? = UIImage(data: imadata! as Data)
        if iamge == nil {
            headIma.image = drawImaSize(image: #imageLiteral(resourceName: "icon_img_3"), size: CGSize(width: 36, height: 36))
        }
        else{
            headIma.image = drawImaSize(image: iamge!, size: CGSize(width: 36, height: 36))
        }
        relationLab.text = StrongGoString(object: relationDic.object(forKey: "RelationName"))
        phoneLab.text = StrongGoString(object: relationDic.object(forKey: "RelationPhone"))
        print("relationDic \(relationDic)")
        if Int((relationDic["IsAdmin"] as? NSNumber)!) == 1{
            transferBut.isHidden = true
            deleteBut.isHidden = true
            notTop.constant = -120
            permissionsLab.text = Localizeable(key: "管理员") as String
        }
        else{
            permissionsLab.text = Localizeable(key: "普通成员") as String
            let user = UnarchiveUser()
            if !IsAdmin{
                transferBut.isHidden = true
                deleteBut.isHidden = true
                notTop.constant = -120
            }
        }

    }
    
    @IBAction func transferSelect(_ sender: UIButton?) {
        MBProgressHUD.showMessage(Localizeable(key: "转让中...") as String!)
        let user = UnarchiveUser()
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["UserId": StrongGoString(object: user?.userId),
                                     "DeviceId": StrongGoString(object: relationDic.object(forKey: "DeviceId")),
                                     "UserGroupId": StrongGoString(object: relationDic.object(forKey: "UserGroupId"))])
        MyHttpSessionMar.shared.post(Prefix + "api/User/ChangeMasterUser", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, request) in
            let resultDic = request as! Dictionary<String, Any>
            MBProgressHUD.hide()
            if resultDic["State"] as! Int == 0 {
                MBProgressHUD.showSuccess(Localizeable(key: "转让成功") as String)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.permissionManagers()
                }
            }
            else{
                MBProgressHUD.showError(resultDic["Message"] as! String)
            }
            
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
    }
    
    @IBAction func deleteSelect(_ sender: UIButton?) {
        //        MBProgressHUD.showMessage(Localizeable(key: "删除中...") as String!)
//        print(relationDic)
        let user = UnarchiveUser()
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["UserId":  StrongGoString(object: relationDic.object(forKey: "UserId")),
                                     "DeviceId": StrongGoString(object: relationDic.object(forKey: "DeviceId")),
                                     "UserGroupId": StrongGoString(object: relationDic.object(forKey: "UserGroupId"))])
        print("requestDic \(requestDic)")
        MyHttpSessionMar.shared.post(Prefix + "api/AuthShare/RemoveShare", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, request) in
            let resultDic = request as! Dictionary<String, Any>
            MBProgressHUD.hide()
            if resultDic["State"] as! Int == 0 {
                MBProgressHUD.showSuccess(Localizeable(key: "删除成功") as String)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.delegateRelation(relationDic: self.relationDic)
                }
            }
            else{
                MBProgressHUD.showError(resultDic["Message"] as! String)
            }
            
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
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
