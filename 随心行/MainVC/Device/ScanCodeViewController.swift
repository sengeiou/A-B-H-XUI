//
//  ScanCodeViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/18.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
import AVFoundation

private let scanAnimationDuration = 3.0//扫描时长

class ScanCodeViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    var scanPane: UIImageView?
    var activityIndicator: UIActivityIndicatorView?
    var scanSession :  AVCaptureSession?
    var activityIndicatorView: UIActivityIndicatorView?
    lazy var scanLine : UIImageView =
        {
            let scanLine = UIImageView()
            scanLine.frame = CGRect(x: 0, y: 0, width: MainScreen.width * 0.6, height: 3)
            scanLine.image = UIImage(named: "QRCode_ScanLine")
            return scanLine
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScan()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUI(){
        title = "绑定手表"
        view.backgroundColor = UIColor.black
        let lab = UILabel(frame: CGRect(x: 20, y: 100, width: MainScreen.width - 40, height: 20))
        lab.text = "将取景框对准二维码，即可自动扫描"
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textAlignment = NSTextAlignment(rawValue: 1)!
        lab.textColor = UIColor.white
        view.addSubview(lab)
        
        let bottomView = UIView(frame: CGRect(x: 0, y: MainScreen.height - 60 - 64, width: MainScreen.width, height: 60))
        bottomView.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
        let lightBut = UIButton(type: UIButtonType.init(rawValue: 0)!)
        lightBut.frame = CGRect(x: 0, y: 0, width: 40, height: 54)
        lightBut.center = CGPoint(x: MainScreen.width/2, y: bottomView.frame.height/2)
        lightBut.addTarget(self, action: #selector(lightBut(sender:)), for: UIControlEvents.touchUpInside)
        lightBut.setImage(UIImage(named: "qrcode_scan_btn_flash_nor"), for: .normal)
        lightBut.setImage(UIImage(named: "qrcode_scan_btn_flash_down"), for: .selected)
        bottomView.addSubview(lightBut)
        view.addSubview(bottomView)
        
        let width = MainScreen.width * 0.6
        scanPane = UIImageView(frame: CGRect(x: (MainScreen.width - width)/2, y: lab.frame.maxY + 20, width: width, height: width * (5/6)))
        scanPane?.image = UIImage(named: "QRCode_ScanBox")
        scanPane?.addSubview(scanLine)
        view.addSubview(scanPane!)
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView?.center = CGPoint(x: (scanPane?.frame.width)!/2, y: (scanPane?.frame.height)!/2)
        activityIndicatorView?.hidesWhenStopped = true;
        scanPane?.addSubview(activityIndicatorView!)
        setupScanSession()
    }

    func setupScanSession()
    {
        do
        {
            //设置捕捉设备
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            //设置设备输入输出
            let input = try AVCaptureDeviceInput(device: device)
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //设置会话
            let  scanSession = AVCaptureSession()
            scanSession.canSetSessionPreset(AVCaptureSessionPresetHigh)
            
            if scanSession.canAddInput(input)
            {
                scanSession.addInput(input)
            }
            
            if scanSession.canAddOutput(output)
            {
                scanSession.addOutput(output)
            }
            
            //设置扫描类型(二维码和条形码)
            output.metadataObjectTypes = [
                AVMetadataObjectTypeQRCode,
                AVMetadataObjectTypeCode39Code,
                AVMetadataObjectTypeCode128Code,
                AVMetadataObjectTypeCode39Mod43Code,
                AVMetadataObjectTypeEAN13Code,
                AVMetadataObjectTypeEAN8Code,
                AVMetadataObjectTypeCode93Code]
            //预览图层
            let scanPreviewLayer = AVCaptureVideoPreviewLayer(session:scanSession)
            scanPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            scanPreviewLayer!.frame = view.layer.bounds
            
            view.layer.insertSublayer(scanPreviewLayer!, at: 0)
            print(scanPreviewLayer!.frame)
            //设置扫描区域
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil, using: { (noti) in
                output.rectOfInterest = (scanPreviewLayer?.metadataOutputRectOfInterest(for: (self.scanPane?.frame)!))!
            })
            //保存会话
            self.scanSession = scanSession
        }
        catch
        {
            //摄像头不可用
            let aler = UIAlertController.init(title: "温馨提示", message: "摄像头不可用", preferredStyle:.alert)
            let entureAction = UIAlertAction(title: "确定", style: .destructive, handler: { (UIAlertAction) in
                
            })
            aler.addAction(entureAction)
            self.present(aler, animated: true, completion: nil)
            return
        }
    }
    
    //开始扫描
    fileprivate func startScan()
    {
        scanLine.layer.add(scanAnimation(), forKey: "scan")
        guard let scanSession = scanSession else { return }
        if !scanSession.isRunning
        {
            scanSession.startRunning()
        }
    }
    
    //扫描动画
    private func scanAnimation() -> CABasicAnimation
    {
        let startPoint = CGPoint(x: scanLine .center.x  , y: 1)
        let endPoint = CGPoint(x: scanLine.center.x, y: (scanPane?.bounds.size.height)! - 2)
        let translation = CABasicAnimation(keyPath: "position")
        translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        translation.fromValue = NSValue(cgPoint: startPoint)
        translation.toValue = NSValue(cgPoint: endPoint)
        translation.duration = scanAnimationDuration
        translation.repeatCount = MAXFLOAT
        translation.autoreverses = true
        return translation
    }

    ///闪光灯
    private func turnTorchOn(lightOn: Bool){
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else
        {
            if lightOn
            {
                let aler = UIAlertController.init(title: "温馨提示", message: "闪光灯不可用", preferredStyle:.alert)
                let entureAction = UIAlertAction(title: "确定", style: .destructive, handler: { (UIAlertAction) in
                    
                })
                aler.addAction(entureAction)
                self.present(aler, animated: true, completion: nil)
            }
            return
        }
        if device.hasTorch
        {
            do
            {
                try device.lockForConfiguration()
                if lightOn && device.torchMode == .off{
                    device.torchMode = .on
                }
                if !lightOn && device.torchMode == .on{
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            }
            catch{ }
        }
    }
    
    func lightBut(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        turnTorchOn(lightOn: sender.isSelected)
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //停止扫描
        self.scanLine.layer.removeAllAnimations()
        self.scanSession!.stopRunning()
        //扫完完成
        if metadataObjects.count > 0{
            if let resultObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject
            {
                let relationVC = RelationViewController(nibName: "RelationViewController", bundle: nil)
                relationVC.isGuardian = true
                
//                self.navigationController?.pushViewController(relationVC, animated: true)
//                return

                print(resultObj.stringValue)
                activityIndicatorView?.startAnimating()// 开始旋转
                let httpMar = MyHttpSessionMar.shared
                let parameterDic = RequestKeyDic()
                parameterDic.addEntries(from: ["SerialNumber":resultObj.stringValue,"UserId": String.init(format: "%d", Defaultinfos.getIntValueForKey(key: UserID))])
                print(parameterDic)
                httpMar.post(Prefix + "api/Device/CheckDevice", parameters: parameterDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    print(result!)
                    let dic = result as! Dictionary<NSString, Any>
                    let relationVC = RelationViewController(nibName: "RelationViewController", bundle: nil)
                    let user = getNewUser()
                    user.userId = String(format: "%d", Defaultinfos.getIntValueForKey(key: UserID))
                    user.deviceId = String(format: "%d", dic["DeviceId"] as! Int)
//                    let fmdb = FMDbase.shared()
                   relationVC.user = user
                    //记录已选中设备信息
                    
                    if dic["State"] as! Int == 0{
//                        let userInfo = UnarchiveUser()
//                        userInfo?.deviceId = String(format: "%d", dic["DeviceId"] as! Int)
//                        ArchiveRoot(userInfo: userInfo!)
//                         fmdb.insertUserInfo(userInfo: user)
                        
                        relationVC.isGuardian = true
                        self.navigationController?.pushViewController(relationVC, animated: true)
                    }
                    else if dic["State"] as! Int == 1107{
                        relationVC.isGuardian = false
                        self.navigationController?.pushViewController(relationVC, animated: true)
                    }
                    else{
                        MBProgressHUD.showError(StrongGoString(object: dic["Message"]))
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.activityIndicatorView?.stopAnimating()
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.showError(Error.localizedDescription)
                    self.startScan()
                    self.activityIndicatorView?.stopAnimating()
                })
            }
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
