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
    @IBOutlet weak var relationFile: UITextField!
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func createUI() {
        title = StrongGoString(object: relationDic.object(forKey: "RelationName"))
        headIma.layer.masksToBounds = true
        headIma.layer.cornerRadius = headIma.frame.height/2
        relationFile.isEnabled = false
        relationFile.clearButtonMode = .whileEditing
        print(relationDic)
        headIma.sd_setImage(with: URL(string: StrongGoString(object: relationDic.object(forKey: "Avatar"))), placeholderImage: #imageLiteral(resourceName: "icon_img_3"))
        relationFile.text = StrongGoString(object: relationDic.object(forKey: "RelationName"))
        phoneLab.text = StrongGoString(object: relationDic.object(forKey: "RelationPhone"))
        print("relationDic \(relationDic)")
        if Int((relationDic["IsAdmin"] as? NSNumber)!) == 1{
            transferBut.isHidden = true
            deleteBut.isHidden = true
            notTop.constant = -120
            permissionsLab.text = Localizeable(key: "管理员") as String
            
            let backbut = UIButton(type: UIButtonType(rawValue: 0)!)
            backbut.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            backbut.setTitle(Localizeable(key: "保存") as String, for: .normal)
            backbut.addTarget(self, action: #selector(saveSelector), for: UIControlEvents.touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backbut)
        }
        else{
            permissionsLab.text = Localizeable(key: "普通成员") as String
            let user = UnarchiveUser()
            if !IsAdmin{
                transferBut.isHidden = true
                deleteBut.isHidden = true
                notTop.constant = -120
            }
            //            if user?.userPh == StrongGoString(object: relationDic.object(forKey: "RelationPhone")) {
            relationFile.isEnabled = true
            let backbut = UIButton(type: UIButtonType(rawValue: 0)!)
            backbut.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            backbut.setTitle(Localizeable(key: "保存") as String, for: .normal)
            backbut.addTarget(self, action: #selector(saveSelector), for: UIControlEvents.touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backbut)
            //            }
        }
    }
    
    func saveSelector(){
        let requestDic = RequestKeyDic()
        MBProgressHUD.showMessage(Localizeable(key: "保存中...") as String!)
        requestDic.addEntries(from: ["RelationName": relationFile.text!,
                                     "UserId": StrongGoString(object: relationDic.object(forKey: "UserId")),
                                     "DeviceId": StrongGoString(object: relationDic.object(forKey: "DeviceId"))])
        MyHttpSessionMar.shared.post(Prefix + "api/AuthShare/UpdateRelationName", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            MBProgressHUD.hide()
            let resDic = result as! Dictionary<String,Any?>
            if resDic["State"] as! Int == 0{
                MBProgressHUD.showSuccess(Localizeable(key: "保存成功") as String)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }else{
                MBProgressHUD.showError(resDic["Message"] as! String)
            }
            
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
    }
    
    @IBAction func transferSelect(_ sender: UIButton?) {
        
        let aler = UIAlertController(title: Localizeable(key: "是否转让管理员权限给该联系人？") as String, message: nil, preferredStyle: .alert)
        let refuseAct = UIAlertAction(title: Localizeable(key: "取消") as String, style: .default, handler: { (UIAlertAction) in
        })
        let consentAct = UIAlertAction(title: Localizeable(key: "转让") as String, style: .default, handler: { (UIAlertAction) in
            MBProgressHUD.showMessage(Localizeable(key: "转让中...") as String!)
            let user = UnarchiveUser()
            let requestDic = RequestKeyDic()
            requestDic.addEntries(from: ["UserId": StrongGoString(object: user?.userId),
                                         "DeviceId": StrongGoString(object: self.relationDic.object(forKey: "DeviceId")),
                                         "UserGroupId": StrongGoString(object: self.relationDic.object(forKey: "UserGroupId"))])
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
            
        })
        aler.addAction(refuseAct)
        aler.addAction(consentAct)
        present(aler, animated: true, completion: {
            
        })
        
    }
    
    @IBAction func deleteSelect(_ sender: UIButton?) {
        
        let aler = UIAlertController(title: Localizeable(key: "是否删除该联系人？") as String, message: nil, preferredStyle: .alert)
        let refuseAct = UIAlertAction(title: Localizeable(key: "取消") as String, style: .default, handler: { (UIAlertAction) in
        })
        let consentAct = UIAlertAction(title: Localizeable(key: "删除") as String, style: .default, handler: { (UIAlertAction) in
            MBProgressHUD.showMessage(Localizeable(key: "删除中...") as String!)
            let requestDic = RequestKeyDic()
            requestDic.addEntries(from: ["UserId":  StrongGoString(object: self.relationDic.object(forKey: "UserId")),
                                         "DeviceId": StrongGoString(object: self.relationDic.object(forKey: "DeviceId")),
                                         "UserGroupId": StrongGoString(object: self.relationDic.object(forKey: "UserGroupId"))])
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
            
        })
        aler.addAction(refuseAct)
        aler.addAction(consentAct)
        present(aler, animated: true, completion: {
            
        })
        
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
