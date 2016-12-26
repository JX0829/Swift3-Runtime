//
//  JXTextField-RT.swift
//  Swift-Runtime
//
//  Created by XiaoLai－JX on 16/12/23.
//  Copyright © 2016年 XiaoLai－JX. All rights reserved.
//

import UIKit

extension UILabel {
    //根据title来设置frame
    struct JXRuntimeKey {
        static var maxWidth = "JXLimitedWidth"
        static var contentSize = "JXContentSize"
    }
    
    var JXMaxWidth:CGFloat? {
        get {
            return objc_getAssociatedObject(self, &JXRuntimeKey.maxWidth) as? CGFloat
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &JXRuntimeKey.maxWidth, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    var JXContentSize:CGSize? {
        get {
            return objc_getAssociatedObject(self, &JXRuntimeKey.contentSize) as? CGSize
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &JXRuntimeKey.contentSize, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    //方法一：通过便利函数(便利构造函数通常用在对系统的类进行构造函数的扩充时使用)
    /*
     1.便利构造函数通常都是写在 extension 里面
     2.便利构造函数init前面加上 convenience
     3.在便利构造函数中需要调用self.init()
    */
    convenience init(frame: CGRect,maxWidth:CGFloat?,str:String?) {
        self.init()
        self.text = str
        self.frame = frame
        self.getContentSize(maxWidth: maxWidth)
    }
    //方法二：利用Runtime的方法交叉（Method Swizzling）
    open override class func initialize() {
        struct Static {
            static var token = NSUUID().uuidString
        }
        
        if self != UILabel.self {
            return
        }
        
        DispatchQueue.once(token: Static.token) { 
            let originalSelector = #selector(UILabel.init(frame:))
            let swizzledSelector = #selector(UILabel.jx_init(frame:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
            let didAddMethod:Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            }else{
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    //swizzled
    func jx_init(frame:CGRect) -> UILabel {
        let _self = self.jx_init(frame: frame)
        print("swizzled jx_init")
        return _self
    }
    
    //获取内容的size
    func getContentSize(maxWidth:CGFloat?) {
        //获取文字尺寸
        let options:NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin
        var size = frame.size
        if maxWidth != nil {
            size.width = maxWidth!
        }
        guard let boundingRect = self.text?.boundingRect(with: CGSize(width:size.width, height:0), options: options, attributes:[NSFontAttributeName:self.font], context: nil) else {
            print("boundingRect set failed")
            return
        }
        self.numberOfLines = 0
        self.lineBreakMode = .byCharWrapping
        self.frame.size = boundingRect.size
    }
}

extension DispatchQueue {
    private static var onceTracker = [String]()
    
    open class func once(token: String, block:() -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}

