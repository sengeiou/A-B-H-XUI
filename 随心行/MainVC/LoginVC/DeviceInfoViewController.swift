//
//  DeviceInfoViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/25.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
import MobileCoreServices

class DeviceInfoViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,photoSelectDelegate {
    
    @IBOutlet weak var deviceRelat: UITextField!
    @IBOutlet weak var devicePh: UITextField!
    @IBOutlet weak var devicePhoto: UIButton!
    @IBOutlet weak var photoTop: NSLayoutConstraint!
    @IBOutlet weak var relationLab: UILabel!
    var user: UserInfo?
    var picker: UIImagePickerController?
    var changeDevice: Bool! = false
    var changeUser: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func initializeMethod() {
        user = UnarchiveUser()!
        if (user?.deviceIma == nil) {
            user?.deviceIma = UIImageJPEGRepresentation(UIImage(named: "icon_img_3")!, 1)?.base64EncodedString()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(not:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(not:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if changeDevice {
            MBProgressHUD.showMessage(Localizeable(key: "正在查询...") as String)
            let requestDic = RequestKeyDic()
            requestDic.addEntries(from: ["DeviceId": (user?.deviceId)!,
                                         "UserId": (user?.userId)!])
            MyHttpSessionMar.shared.post(Prefix + "api/Person/GetPersonProfile", parameters: requestDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                let resultDic = result as! Dictionary<String, Any>
                MBProgressHUD.hide()
                if resultDic["State"] as! Int == 0{
                    let items:Dictionary<String, Any> = resultDic["Item"] as! Dictionary<String, Any>
                    var url = StrongGoString(object: items["Avatar"])
                    if url == ""{
                        url = "0"
                    }
                    downloadedFrom(url: URL(string: url)!, callBack: { (Image) in
                        let imaData: String? = UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()
                        if imaData != nil{
                            DispatchQueue.main.async() { () -> Void in
                                self.devicePhoto.setBackgroundImage(Image, for: .normal)
                            }
                        }
                    })
                    self.deviceRelat.text = StrongGoString(object: items["Nickname"])
                    self.devicePh.text = StrongGoString(object: items["Sim"])
                    print(items)
                }
                else{
                    MBProgressHUD.showError(resultDic["Message"] as! String)
                }
                
            }, failure: { (URLSessionDataTask, Error) in
                MBProgressHUD.hide()
                MBProgressHUD.showError(Error.localizedDescription)
            })
            
        }
    }
    
    func createUI() {
        title = Localizeable(key: "手表信息") as String
        devicePhoto.layer.masksToBounds = true
        devicePhoto.layer.cornerRadius = 75.0/2
        devicePh.delegate = self
        deviceRelat.delegate = self
        
        if changeUser {
            title = Localizeable(key: "账号信息") as String
            deviceRelat.placeholder = Localizeable(key: "请输入昵称") as String
            deviceRelat.text = user?.userName
            devicePh.text = user?.userPh
            relationLab.text = Localizeable(key: "昵称") as String
            print(logUser(user: user!))
            let imadata = NSData(base64Encoded: user?.userIma ?? "", options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
            let iamge: UIImage? = UIImage(data: imadata! as Data)
            
            if (iamge != nil) {
                self.devicePhoto.setBackgroundImage(iamge, for: .normal)
            }
        }
    }
    
    func keyboardWillShow(not:Notification){
        // 1.取出键盘的frame
        //       let keyBoardF = not.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        // 2.取出键盘弹出的时间
        let duration = not.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -100)
        }
    }
    
    func keyboardWillHidden(not:Notification){
        let duration = not.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.view.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func photoSelect(_ sender: UIButton) {
        let poView = PhotoView(frame: MainScreen)
        let appDelete = UIApplication.shared.delegate as! AppDelegate
        appDelete.window?.addSubview(poView)
        poView.clickValueClosure { (Button) in
            print(Button!)
            let sourceType: UIImagePickerControllerSourceType
            switch Button!.tag {
            case 101:
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = UICollectionViewScrollDirection.vertical
                layout.sectionInset = UIEdgeInsetsMake(8, 10, 10, 10)
                layout.itemSize = CGSize(width: (MainScreen.width - 40)/3, height: (MainScreen.width - 40)/3 * 1.1)
                let selectVC = SelectPhotoCollectionViewController(collectionViewLayout: layout)
                selectVC.imaArr = [UIImage(named: "icon_img_3")!,UIImage(named: "icon_img_1")!,UIImage(named: "icon_img_2")!]
                if self.changeUser {
                    selectVC.imaArr = [UIImage(named: "icon_img_3")!,UIImage(named: "icon_img_4")!,UIImage(named: "icon_img_5")!,UIImage(named: "icon_img_6")!,UIImage(named: "icon_img_7")!]
                }
                selectVC.delegate = self;
                //                let selectVC = SelectPhotoCollectionViewController(nibName: "SelectPhotoCollectionViewController", bundle: nil)
                self.navigationController?.pushViewController(selectVC, animated: true)
                break;
            case 102:
                sourceType = UIImagePickerControllerSourceType.init(rawValue: 1)!
                if (UIImagePickerController.isSourceTypeAvailable(sourceType)){
                    if (self.picker == nil){
                        self.picker = UIImagePickerController()
                        self.picker?.delegate = self
                        self.picker?.allowsEditing = true
                    }
                    self.picker?.sourceType = sourceType
                    self.present(self.picker!, animated: true, completion: {
                        
                    })
                }
                else{
                    MBProgressHUD.showError(Localizeable(key: "相机不可用") as String!)
                }
                break;
            default:
                sourceType = UIImagePickerControllerSourceType(rawValue: 0)!
                if (UIImagePickerController.isSourceTypeAvailable(sourceType)){
                    if (self.picker == nil){
                        self.picker = UIImagePickerController()
                        self.picker?.delegate = self
                        self.picker?.allowsEditing = true
                    }
                    self.picker?.sourceType = sourceType
                    self.present(self.picker!, animated: true, completion: {
                        
                    })
                }
                else{
                    MBProgressHUD.showError(Localizeable(key: "相删不可用") as String)
                }
                break;
            }
        }
    }
    
    @IBAction func confimSelect(_ sender: UIButton) {
        if deviceRelat.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入关系") as String!)
            return
        }
        if devicePh.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入号码") as String!)
            return
        }
        MBProgressHUD.showMessage(Localizeable(key: "保存中...") as String!)
        
        if changeUser {
            let dic = RequestKeyDic()
            dic.addEntries(from: [ "UserId": user!.userId!,
                                   "Username": deviceRelat.text!,
                                   "Email": "",
                                   "Address": "",
                                   "Avatar": user!.userIma!,
                                   "CellPhone": "",
                                   "Sim": devicePh.text!,
                                   "Gender": true,
                                   "Birthday": "",
                                   "Weight": 0,
                                   "Height": 0,
                                   "Steps": 0,
                                   "Distance": 0,
                                   "SportTime": 0,
                                   "Calorie": 0
                ])
            let httpMan = MyHttpSessionMar.shared
            httpMan.post(Prefix + "api/User/EditUserInfo", parameters: dic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                MBProgressHUD.hide()
                let resDic = result as! Dictionary<String,Any?>
                if resDic["State"] as! Int == 0{
                    MBProgressHUD.showSuccess(Localizeable(key: "保存成功") as String)
                    self.user?.userName = self.deviceRelat.text
                    ArchiveRoot(userInfo: self.user!)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { 
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                else{
                    MBProgressHUD.showError(dic["Message"] as! String)
                }
                
            }, failure: { (URLSessionDataTask, Error) in
                MBProgressHUD.hide()
                MBProgressHUD.showError(Error.localizedDescription)
            })
            return
        }
        
        let dic = RequestKeyDic()
        dic.addEntries(from: ["Item":["Birthday": "",
                                      "DeviceID": user!.deviceId!,
                                      "Gender": "",
                                      "Grade": "",
                                      "Height": "",
                                      "Nickname": deviceRelat.text!,
                                      "UpdateTime": "",
                                      "Weight": "",
                                      "Avatar": user!.deviceIma!,
                                      "UserId": Defaultinfos.getIntValueForKey(key: UserID),
                                      "Sim": devicePh.text!,
                                      "Age": "",
                                      "BloodType": "",
                                      "CellPhone": "",
                                      "CellPhone2": "",
                                      "Address": "",
                                      "Breed": "",
                                      "IDnumber": "",
                                      "Remark": "",
                                      "MarkerColor": ""]])
        
        let httpMan = MyHttpSessionMar.shared
        httpMan.post(Prefix + "api/Person/SavePersonProfile", parameters: dic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            MBProgressHUD.hide()
            let resDic = result as! Dictionary<String,Any?>
            if resDic["State"] as! Int == 0{
                print("资料设置完成")
                self.user?.devicePh = self.devicePh.text!
                self.user?.deviceName = self.deviceRelat.text!
                let fmdbase = FMDbase.shared()
                fmdbase.insertUserInfo(userInfo: self.user!)
                ArchiveRoot(userInfo: self.user!)
                print("归档数据 \(UnarchiveUser()) \n 数据库 \(FMDbase.shared().selectUser(userid: (self.user?.userId)!, deviceid: (self.user?.deviceId)!))")
                let homeVC = HomeViewController()
                homeVC.tabBarItem = UITabBarItem(title: "主页", image: UIImage(named: "tab_home_pre"), tag: 1001)
                let homeNav = NavViewController(rootViewController: homeVC)
                
                let messVC = MessTableViewController(nibName: "MessTableViewController", bundle: nil)
                messVC.tabBarItem = UITabBarItem(title: "消息", image: UIImage(named: "tab_messg_pre"), tag: 1002)
                let messNav = NavViewController(rootViewController: messVC)
                
                let meVC = MeTableViewController(nibName: "MeTableViewController", bundle: nil)
                meVC.tabBarItem = UITabBarItem(title: "我的", image: #imageLiteral(resourceName: "tab_mine_pre"), tag: 1003)
                let meNav = NavViewController(rootViewController: meVC)
                
                let tabVC = UITabBarController()
                tabVC.viewControllers = [homeNav,messNav,meNav]
                
                UIApplication.shared.keyWindow?.rootViewController = tabVC
                
            }
            else{
                MBProgressHUD.showError(dic["Message"] as! String)
            }
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage?
        if ((info[UIImagePickerControllerMediaType] as! String) == kUTTypeImage as String) {
            image = info[UIImagePickerControllerEditedImage] as? UIImage
            let baseData = UIImageJPEGRepresentation(image!, 1)?.base64EncodedString()
            print("头像 \(image?.size)  (((  \(info)")
            if changeUser {
                user?.userIma = baseData
            }
            else{
                user?.deviceIma = baseData
            }
        }
        dismiss(animated: true) {
            guard (image != nil) else{
                return
            }
            self.devicePhoto.setBackgroundImage(image, for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == deviceRelat) {
            devicePh.becomeFirstResponder()
        }
        else{
            devicePh.resignFirstResponder()
        }
        return true
    }
    
    public func photoSlectIndex(index: Int) {
        var arr = [UIImage(named: "icon_img_3")!,UIImage(named: "icon_img_1")!,UIImage(named: "icon_img_2")!]
        if self.changeUser {
            arr = [UIImage(named: "icon_img_3")!,UIImage(named: "icon_img_4")!,UIImage(named: "icon_img_5")!,UIImage(named: "icon_img_6")!,UIImage(named: "icon_img_7")!]
        }
        devicePhoto.setBackgroundImage(arr[index], for: .normal)
        let baseData = UIImageJPEGRepresentation(arr[index], 1)?.base64EncodedString()
        if self.changeUser {
            user?.userIma = baseData
        }
        else{
            user?.deviceIma = baseData
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
