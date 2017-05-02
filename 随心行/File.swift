//
//  File.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/6.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
import AFNetworking

let MainScreen = UIScreen.main.bounds

let FirstLun = "FIRSTLUN"

let AccountToken = "TOKEN"

let Account = "ACCOUNT"

let UserID = "USERID"

/*请求前缀*/
let Prefix = "http://openapi.5gcity.com/"

/*请求头*/
let Head = "3A73DE89-2C32-4DD8-A8F8-B43C1FC26C17"

func userAccountPath() -> String {
    return (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask,true).first! as NSString).appendingPathComponent("userAccount.data") as String
}

/*归档登录信息*/
func ArchiveRoot(userInfo:UserInfo) {
   let result = NSKeyedArchiver.archiveRootObject(userInfo, toFile: userAccountPath())
    print(result)
}

/*解档登录信息*/
func UnarchiveUser() -> UserInfo? {
    return NSKeyedUnarchiver.unarchiveObject(withFile:userAccountPath()) as? UserInfo
}

func getNewUser() -> UserInfo {
    let user = UserInfo()
    user.userId = ""
    user.userPh = ""
    user.deviceId = ""
    user.devicePh = ""
    user.deviceIma = ""
    user.relatoin = ""
    user.userName = ""
    user.userPass = ""
    user.userIma = ""
    return user
}

func logUser(user: UserInfo){
    print("user.userId: \(user.userId) \n user.userPh: \(user.userPh) \n user.deviceId: \(user.deviceId) \n user.devicePh: \(user.devicePh) \n user.deviceIma: \(user.deviceIma) \n user.relatoin: \(user.relatoin) \n user.userName: \(user.userName) \n user.userPass: \(user.userPass) \n user.userIma: \(user.userIma)")
}

func Localizeable(key: NSString) ->NSString {
    return LocalizeableInfo.swiftStaticFunc(translation_key: key)
}

let NotificaCenter = NotificationCenter.default

func ColorFromRGB(rgbValue: Int) -> UIColor{
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(rgbValue & 0xFF)) / 255.0, alpha: 1.0)
}

func systLanage()->String{
    var defaults = Bundle.main.preferredLocalizations.first! as NSString
    defaults = defaults.substring(to: 2) as NSString
    return defaults as String
}

/*整理请求参数中不变参数*/
func RequestKeyDic() -> NSMutableDictionary {
    var token = Defaultinfos.getValueForKey(key: AccountToken)
    if let token1 = token as? String{ //判断类型是否为string
        print(token1)
    }
    else{
        token = ""
    }

    let nsDic : NSMutableDictionary = NSMutableDictionary(dictionary: ["Token" : token!,"Language":systLanage(),"AppId":"71"])
    return nsDic
}

//检查是否满足包含6-16位数字及英文组合
func CheckText(str: String) -> Bool {
    let regex = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$"
    let pred = NSPredicate(format: "SELF MATCHES %@", regex)
    let result : Bool = pred.evaluate(with: str)
    return result
}

//传入数据强转string
func StrongGoString(object: AnyObject) -> String{
    var str:String = ""
    if let token = object as? String {
        str = token
//        print("是string")
    }
    if let token = object as? Int {
        str = String(format: "%d", token)
//        print("是int")
    }
    return str
}

//类方法扩展
extension UIImage{
    class func ImageWithColor(color: UIColor,size: CGSize) ->UIImage{
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /**
     1.识别图片二维码
     
     - returns: 二维码内容
     */
    func recognizeQRCode() -> String?
    {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        let features = detector?.features(in: CoreImage.CIImage(cgImage: self.cgImage!))
        guard (features?.count)! > 0 else { return nil }
        let feature = features?.first as? CIQRCodeFeature
        return feature?.messageString
    }
}

func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, callBack:((UIImage) -> Void)?) {
//    contentMode = mode
    var image:UIImage = UIImage()
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        let httpurl = response as? HTTPURLResponse
        if  httpurl?.statusCode == 200{
            let mimeYtpe = response?.mimeType
            if (mimeYtpe?.hasPrefix("image"))!{
                image = UIImage(data: data!)!
            }
        }
        callBack!(image)
//        guard
//            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//            let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
//            let data = data, error == nil,
//            let image = UIImage(data: data)
//            else { return }
//        callBack!(image)

        }.resume()
}


extension UIBarButtonItem{
    class func backItem(target: Any?,hidden: Bool,action: Selector) -> UIBarButtonItem{
        let backbut = UIButton(type: UIButtonType(rawValue: 0)!)
        backbut.frame = CGRect(x: 0, y: 0, width: 24, height: 41)
        backbut.isHidden = hidden
        backbut.setImage(UIImage(named: "icon_return"), for: UIControlState.normal)
        backbut.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        return UIBarButtonItem(customView: backbut)
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
