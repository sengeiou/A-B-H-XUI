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

let WORK_MODE = "0120"        //工作模式
let DORMANT_TIME_BUCKET = "1020"  //晚间时间段
let CHANGE_DEVICE = "2806"  //更换小普夹子
let SOUND_SIZE = "2808"  //音量大小
let LOCATION_REAL_TIME = "0039"  //即时定位
let UPDATA_INTERVAL = "0003"  //上传间隔
let SHIELD_OTHER_PHONE = "2807"  //屏蔽陌生号码开关
let SET_WATCH_PHONE = "2807"  //设置手表号码
let SHIELD_DEVICE = "2814"  //小普夹子开关
let QUERY_TELEHONE_CHARGE = "2804"  //查询话费 cmdValue:app用户手机号码,目标号码,短信内容
let GREET_CMD = "2810"  //问候指令 cmdvalue:app用户的手机号码,问候内容

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
    user.deviceName = ""
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
    let defaus:Array<NSString> = UserDefaults.standard.object(forKey: "AppleLanguages") as! Array
    let defaults = defaus.first?.substring(to: 2)
    return defaults!
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
func StrongGoString(object: Any?) -> String{
    print(type(of: object))
    var str:String = ""
    if let token = object as? String {
        str = token
//        print("是string")
    }
    if let token = object as? Double {
        str = "\(token)"
//        print("是Double")
    }
    if let token = object as? Int {
        str = String(format: "%d", token)
//        print("是int")
    }
   
    return str
}

func drawImaSize(image: UIImage, size: CGSize) -> UIImage {
    //此方法抗锯齿 UIGraphicsBeginImageContextWithOptions
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)//获得用来处理图片的图形上下文。利用该上下文，你就可以在其上进行绘图，并生成图片 ,三个参数含义是设置大小、透明度 （NO为不透明）、缩放（0代表不缩放）
    let imageRect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
    image.draw(in: imageRect)
    let newIma = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newIma!
}

func getNowDateFromatAnDate(anyDate: Date) -> Date{
    //设置源日期时区
    let sourceTimeZone = TimeZone(abbreviation: "GMT")
    //设置转换后的目标日期时区
    let destinationTimeZone = NSTimeZone.system
    //设置转换后与世界标准时间的偏移量
    let sourceGTMOffset = sourceTimeZone?.secondsFromGMT(for: anyDate)
    //目标日期与本地时区偏移量
    let destinationGMTOffset = destinationTimeZone.secondsFromGMT(for: anyDate)
    //得到时间偏移量的差值
    let interval = destinationGMTOffset - sourceGTMOffset!
    //转为现在时间
    let date = Date(timeInterval: TimeInterval(interval), since: anyDate)
    return date
}

////合并两张图片
//func mergeIma(ima: UIImage, ima1: UIImage) -> UIImage{
////    let imgRef1 = ima.cgImage
////    let w1 = imgRef1?.width
////    let h1 = imgRef1?.height
////    
////    let imgRef2 = ima1.cgImage
//   }

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
    
    //合并两张图片
    func mergeIma(ima: UIImage) -> UIImage {
        let size = CGSize(width: self.size.width * 1.5, height: self.size.height * 1.5)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width - 4, height: size.width - 4), cornerRadius: (size.width - 4)/2).addClip()
        ima.draw(in: CGRect(x: 3, y: 3, width: size.width - 6, height: size.width - 6))
        let callBackIma = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return callBackIma!
    }
    
    //绘制圆角图片
    func drawCornerIma(Sise: CGSize?) -> UIImage {
        var imaSise:CGSize? = Sise
        if imaSise == nil {
            imaSise = self.size
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.size.height , height: self.size.height), cornerRadius: (self.size.height)/2).addClip()
        self.draw(in: CGRect(x: 0, y: 0, width: (imaSise?.height)! , height: (imaSise?.height)!))
        let callBackIma = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return callBackIma!
    }
    
    //绘制指定大小图片
    func drawSquareIma(Sise: CGSize?) -> UIImage {
        var imaSise:CGSize? = Sise
        if imaSise == nil {
            imaSise = self.size
        }
        var sizeWeigh: CGFloat = (imaSise?.width)!
        if sizeWeigh < (imaSise?.height)! {
            sizeWeigh = (imaSise?.height)!
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: sizeWeigh, height: sizeWeigh), false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: sizeWeigh , height: sizeWeigh))
        let callBackIma = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return callBackIma!
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

func attributedString(strArr: Array<String>, fontArr: Array<UIFont>, colorArr: Array<UIColor>) -> NSMutableAttributedString {
    let attrStr = NSMutableAttributedString()
    for i in 0...(strArr.count - 1) {
        let dic:Dictionary = [NSForegroundColorAttributeName:colorArr[i%2],NSFontAttributeName:fontArr[i%2]]
        attrStr.append(NSAttributedString(string: strArr[i], attributes: dic))
         print(attrStr)
    }
    return attrStr
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
    
   class func buttonWithItem(target: Any?,butIma: UIImage,frame: CGRect, action: Selector) -> UIBarButtonItem {
        let backbut = UIButton(type: UIButtonType(rawValue: 0)!)
        backbut.frame = frame
        backbut.setImage(butIma, for: UIControlState.normal)
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

extension UIButton{
    enum ButtonEdgeInsetsStyle {
        case buttonddgeinsetsstyletop // image在上，label在下
        case buttonddgeinsetsstyleleft // image在左，label在右
        case buttonddgeinsetsstyletopbottom // image在下，label在上
        case buttonddgeinsetsstyletopright // image在右，label在左
    }
    enum CompassPoint {
        case north,south,ease,west
    }
    
    func layoutButtonWithEdgeInsetsStyle(style: ButtonEdgeInsetsStyle,space: CGFloat) {
        let imageWith = imageView?.frame.width
        let imageHeight = imageView?.frame.height
        var lableWidth: CGFloat? = 0.0
        var lablHeight: CGFloat? = 0.0
        
        let version = UIDevice.current.systemVersion.components(separatedBy: ".") as Array
        if Float(version.first!)! >= 8.0 {
            // 由于iOS8中titleLabel的size为0，用下面的这种设置
            lableWidth = titleLabel?.intrinsicContentSize.width
            lablHeight = titleLabel?.intrinsicContentSize.height
        }
        else{
            lableWidth = titleLabel?.frame.width
            lablHeight = titleLabel?.frame.height
        }
        // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
        var imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        var labelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
        switch style {
        case .buttonddgeinsetsstyletop:
            //        {
            imageEdgeInsets = UIEdgeInsetsMake(CGFloat(-lablHeight!) - space/2.0, 0.0, 0.0, -lableWidth!);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith!, CGFloat(-imageHeight!) - space/2.0, 0);
            //        }
            break
        case .buttonddgeinsetsstyleleft:
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
            break
        case .buttonddgeinsetsstyletopbottom:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, CGFloat(-lablHeight!)-space/2.0, -lableWidth!);
            labelEdgeInsets = UIEdgeInsetsMake(CGFloat(-imageHeight!)-space/2.0, -imageWith!, 0, 0);
            break
        case .buttonddgeinsetsstyletopright:
            imageEdgeInsets = UIEdgeInsetsMake(0.0, CGFloat(lableWidth!)+space/2.0, 0.0, -CGFloat(lableWidth!) - space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0.0, -CGFloat(imageWith!)-space/2.0, 0.0, imageWith!+space/2.0);
            break
        default: break
            
        }
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
}
