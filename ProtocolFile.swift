//
//  ProtocolFile.swift
//  Partys
//
//  Created by 陈健 on 2016/7/14.
//  Copyright © 2016年 陈健. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet
import SVProgressHUD
import URLNavigator
import SwiftWebVC
import AdSupport
import Alamofire

typealias H = () -> ()

///通用的protocol，包含网络请求，alert、页面跳转以及通用的方法
protocol CommonProtocol:class,MusicProtocol,alertProtocol {
    
    func getLocolVersion() -> String
    
    func needToUpdate() -> Bool
    
    func checkUpdate(handler:@escaping ()->())
    
    ///naviigation环境的返回
    func back()
    ///model 的返回
    func dismiss()
    
    /**
     全局方法，用来跳转到播放器实例
     */
    func gotoPlayer()
    
    ///环信登录
    func appSetUp()
    
    
    /**
     跳转到webview
     - parameter url:跳转的链接
     */
//    func toWebVC(url:String)
    
    func rootViewController() -> MainTabBarViewController?
    
    
   
    
   }

//baseviewcontroller alert
///用于在各个页面弹出alertVC
protocol alertProtocol {
    func alert(title:String,message:String)
    func alert(title:String,message:String,firstBlock:@escaping ()->(),secondBlock:(()->())?)
}

///tableView、collectionView 空数据处理
protocol emptyProtocol:DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage!
//
//    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation!
//
//    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!
//
//    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!
//
//    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor!
}



///分享协议
protocol shareProtocol {
    
}

extension shareProtocol {
    
    
}

extension CommonProtocol {
    
    
    
    /**
     全局方法，用来跳转到播放器实例
     */
    func gotoPlayer() {
        //普通播放器
        if self.player() is PlayerViewController {
            self.toCommonPlayer()
        }
            //电台播放器
        else {
            self.toFMPlayer()
        }
        
        
    }
    
    func needToUpdate() -> Bool {
        if let flag = self.loadObjectFromUserDefault(key: NeedUpdate) as? Bool {
            return flag
        }
        else {
            return false
        }
    }
    
    func checkUpdate(handler:@escaping ()->()) {
        self.getAppstoreVersion { [weak self] (version) in
            if version == self?.getLocolVersion() {
                self?.saveToUserDefault(object: false, key: NeedUpdate)
                
            }
            else {
                self?.saveToUserDefault(object: true, key: NeedUpdate)
                
            }
            handler()
        }
    }
    
    func getAppstoreVersion(handler:@escaping (String)->())  {
        Alamofire.request(checkOnlineVersion, method: .get, parameters: [:]).responseJSON { (response) in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let _ = response.result.value {
                    switch response.result {
                    case .success:
                        handler("")
                        break
                        
                    case .failure(let error):
                        print(error)
                        
                        break
                    }
                }
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    
    func getLocolVersion() -> String {
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as? String
        return version ?? ""
    }
    
    func rootViewController() -> MainTabBarViewController? {
        return UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController
    }
    
    
    
    ///环信登录
    func appSetUp() {
        if let userid = self.getBasicInfo()?.id {
            guard EMClient.shared().login(withUsername: "\(userid)", password: "123456") == nil else {
                print("环信登录失败 error")
                return
            }
            
            GeTuiSdk.bindAlias("\(userid)", andSequenceNum: "seq-1")
            let tagNames:NSArray = ["test","iOS","ios"]
            if !(GeTuiSdk.setTags(tagNames as [AnyObject])) {
                print("设置标签失败")
            }
        }
        
        
        
    }
    
    func isMySelf(userId:Int?) -> Bool {
        //自己
        if userId == self.getBasicInfo()?.id && userId != nil {
            return true
        }
            //别人
        else {
            //            self.messageBtn.isHidden = false
            return false
        }
    }
    
       
}

//MARK: - 私有方法
extension CommonProtocol {
    
}

extension CommonProtocol where Self:UIViewController{
    
    
    
    func back() {

        guard self.navigationController != nil else {
            print("vc is not navigationController")
            return
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    /**
     跳转到webview
     - parameter url:跳转的链接
     */
//    func toWebVC(url:String) {
//        let webVC = SwiftModalWebVC(urlString: url)
//        self.parent?.present(webVC, animated: true, completion: nil)
//    }
 
//
//    func showBackItem(vc:commonProtocol) {
//        
//        
//        let backBtn = UIButton(type: .custom)
//        backBtn.frame = CGRect(x: 0, y: 0, width: 55, height: 35)
//        backBtn.setTitle("                              ", for: .normal)
//        backBtn.setImage(UIImage(named: "backIcon-common"), for: .normal)
//        backBtn.addTarget(vc, action: #selector(goback), for: .touchUpInside)
//        let backItem = UIBarButtonItem(customView: backBtn)
//        //                (vc as! UIViewController).navigationController?.navigationItem.backBarButtonItem?.setBackgroundImage(UIImage(named: "backIcon-common"), forState: .Normal, barMetrics: .Default)
//        
//        
//        
//        (vc as! UIViewController).navigationItem.leftBarButtonItem = backItem
//    }
//    func goback() {
//        (vc as! UIViewController).navigationController?.popViewControllerAnimated(true)
//    }
    
}



extension alertProtocol where Self:UIViewController{
    func alert(title:String,message:String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle:.alert)
        let action = UIAlertAction(title: "确定", style: .default) { (_) in
            alertVC.dismiss(animated: true, completion: {
                
            })
        }
        alertVC.addAction(action)
        self.present(alertVC, animated: true) {
            
        }
    }
    
    func alert(title:String,message:String,firstBlock:@escaping ()->(),secondBlock:(()->())?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle:.alert)
        let action = UIAlertAction(title: "确定", style: .default) { (_) in
            firstBlock()
        }
        let action1 = UIAlertAction(title: "取消", style: .default) { (_) in
            if secondBlock != nil {
                secondBlock!()
            }
            
            alertVC.dismiss(animated: true, completion: {
                
            })
        }
        alertVC.addAction(action)
        alertVC.addAction(action1)
        self.present(alertVC, animated: true) {
            
        }
        
    }
}

extension emptyProtocol {
//    //MARK: - EmptyData delegate
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "defaultLarge-pic")
//    }
//    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
//        let animation = CABasicAnimation(keyPath: "transform")
//        animation.fromValue = NSValue(caTransform3D:CATransform3DIdentity)
//        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat.pi/2, 0.0, 0.0, 1.0))
//        animation.duration = 0.25
//        animation.isCumulative = true
//        animation.repeatCount = MAXFLOAT
//        return animation
//    }
//
//    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let title = "暂时没有内容哦~"
//
//        let attributes = [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 18.0),
//                          NSForegroundColorAttributeName: UIColor.white]
//
//        return NSAttributedString(string: title, attributes: attributes)
//    }
//
//    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let title = "稍后过来看看吧！"
//
//        let paragraph = NSMutableParagraphStyle()
//        paragraph.lineBreakMode = .byWordWrapping
//        paragraph.alignment = .center
//        let attributes = [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 14.0),
//                          NSForegroundColorAttributeName: UIColor.white,
//                          NSParagraphStyleAttributeName: paragraph]
//        return NSAttributedString(string: title, attributes: attributes)
//    }
//
//    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
//        //        return UIColor(red: 236/255, green: 240/255, blue: 243/255, alpha: 1)
//        //        return UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)
//        return UIColor.white
//    }
//
//    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
//        return true
//    }
    
    
    
}

protocol staticProtocol:NetworkProtocol {
    
}


extension staticProtocol {
    
}


protocol customNavigationItem {
    func setupNavigationItems()
}

extension customNavigationItem where Self:UIViewController {
    
    func setupNavigationItems() {
            // use the feature only available in iOS 9
            // for ex. UIStackView
//            self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -12, 0, -12)
//            self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 12, 0, 12)
            for item in self.navigationItem.leftBarButtonItems ?? [] {
//                if #available(iOS 11.0, *) {
//                    item.imageInsets = UIEdgeInsetsMake(0, -12, 0, 0)
//                }
                
                item.tintColor = UIColor(hex: "BDBDBD")
            }
            for item in self.navigationItem.rightBarButtonItems ?? [] {
//                if #available(iOS 11.0, *) {
//                    item.imageInsets = UIEdgeInsetsMake(0, 0, 0, -12)
//                }
                
                item.tintColor = UIColor(hex: "BDBDBD")
            }

    }
    
    func setNavigationText() {
        if #available(iOS 9.0, *) {
            // use the feature only available in iOS 9
            // for ex. UIStackView
            //            self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -12, 0, -12)
            //            self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 12, 0, 12)
            for item in self.navigationItem.leftBarButtonItems ?? [] {
//                item. = UIEdgeInsetsMake(0, -12, 0, 0)
                item.customView?.center = CGPoint(x:item.customView!.center.x - 12,y:item.customView!.center.y)
                item.tintColor = UIColor(hex: "6178F0")
//                item.tintColor = UIColor.red
//                if #available(iOS 11.0, *) {
//                    item.setTitlePositionAdjustment(UIOffsetMake(-12, 0), for: .default)
//                }
                
                
            }
            for item in self.navigationItem.rightBarButtonItems ?? [] {
//                item.imageInsets = UIEdgeInsetsMake(0, 0, 0, -12)
                item.customView?.center = CGPoint(x:item.customView!.center.x + 12,y:item.customView!.center.y)
                
                item.tintColor = UIColor(hex: "6178F0")
//                if #available(iOS 11.0, *) {
//                    item.setTitlePositionAdjustment(UIOffsetMake(12, 0), for: .default)
//                }
            }
            
        } else {
            // or use some work around
        }
    }
}
