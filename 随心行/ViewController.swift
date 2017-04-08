//
//  ViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/6.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UIScrollViewDelegate {

    fileprivate var timer : Timer?
    fileprivate var but : UIButton?
    fileprivate var tapView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    func createUI(){
        let scrollview = UIScrollView(frame: CGRect(x: 0, y: 0, width: MainScreen.width, height: MainScreen.height))
        scrollview.contentSize = CGSize(width: MainScreen.width * 3, height: MainScreen.height)
        scrollview.isPagingEnabled = true
        scrollview.delegate = self
        view.addSubview(scrollview);
        let titleArr = [Localizeable(key: "first_lun"), Localizeable(key: "实时精确定位"),Localizeable(key: "问声好")];
        let detailTitArr = [Localizeable(key: "随时随地守护父母健康"), Localizeable(key: "危急时刻爸妈位置秒知道"),Localizeable(key: "每天从问候父母开始")];
        for i in 0...2 {
            print(i)
            let imageView = UIImageView(frame: CGRect(x: 0 + MainScreen.width * CGFloat(i), y: 0, width: MainScreen.width, height: MainScreen.height))
            imageView.image = UIImage(named: NSString.init(format: "default_yd_%d_", Int(i) + 1) as String)
            scrollview.addSubview(imageView)
            
            let lable = UILabel(frame: CGRect(x: 0, y: MainScreen.height - 70, width: MainScreen.width, height: 30))
            lable.font = UIFont.systemFont(ofSize: 20)
            lable.textAlignment = NSTextAlignment(rawValue: 1)!
            lable.text = detailTitArr[i] as String
            lable.textColor = ColorFromRGB(rgbValue: 0x033ea8)
            imageView.addSubview(lable);
            let lable1 = UILabel(frame: CGRect(x: 0, y: lable.frame.minY - 50, width: MainScreen.width, height: 45))
            lable1.textAlignment = NSTextAlignment(rawValue: 1)!
            lable1.text = titleArr[i] as String
            lable1.font = UIFont.systemFont(ofSize: 36)
            lable1.textColor = ColorFromRGB(rgbValue: 0x033ea8)
            imageView.addSubview(lable1);
            
            if i == 2 {
                imageView.isUserInteractionEnabled = true
                but = UIButton(type: UIButtonType(rawValue: 0)!)
                but?.frame = CGRect(x: 0, y: MainScreen.height + 10, width: MainScreen.width - 120, height: 40)
                but?.layer.masksToBounds = true
                but?.layer.cornerRadius = 20.0
                but?.setTitle(Localizeable(key: "立即体验") as String, for: UIControlState.normal)
                but?.addTarget(self, action: #selector(tapBeginBut(sender:)), for: UIControlEvents.touchUpInside)
                but?.backgroundColor = ColorFromRGB(rgbValue: 0x389aff)
                but?.titleLabel?.textColor = UIColor.white
                imageView.addSubview(but!)
                print(but!)
                but?.center = CGPoint(x: MainScreen.width/2, y: (but?.center.y)!)
            }
        }
    }
    
    func tapBeginBut(sender: UIButton){
        Defaultinfos.putKeyWithInt(key: FirstLun, value: 1)
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        let nav = NavViewController(rootViewController: loginVC)
//        let nav = UINavigationController(rootViewController: loginVC)
        
        UIApplication.shared.keyWindow?.rootViewController = nav
        
    }
    
    func timeOut() {
        UIView .animate(withDuration: 0.5, animations: {
            self.but?.transform = CGAffineTransform(translationX: 0, y: -80)
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x)
        if scrollView.contentOffset.x >= MainScreen.width * 2 {
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timeOut), userInfo: nil, repeats: false)
        }
    }
}

