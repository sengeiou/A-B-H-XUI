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
    var user: UserInfo?
    var picker: UIImagePickerController?
    
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
    }
    
    func createUI() {
        title = Localizeable(key: "手表信息") as String
        devicePhoto.layer.masksToBounds = true
        devicePhoto.layer.cornerRadius = 75.0/2
        devicePh.delegate = self
        deviceRelat.delegate = self
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
        MBProgressHUD.showMessage(Localizeable(key: "请求中...") as String!)
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
            "Sim": "",
            "Age": "",
            "BloodType": "",
            "CellPhone":devicePh.text!,
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
             print("头像")
            user?.deviceIma = baseData

        }
        dismiss(animated: true) {
            guard (image != nil) else{
                return
            }
            self.devicePhoto.setImage(image, for: .normal)
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
        let arr = [UIImage(named: "icon_img_3")!,UIImage(named: "icon_img_1")!,UIImage(named: "icon_img_2")!]
         devicePhoto.setImage(arr[index], for: .normal)
        let baseData = UIImageJPEGRepresentation(arr[index], 1)?.base64EncodedString()
        user?.deviceIma = baseData
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
