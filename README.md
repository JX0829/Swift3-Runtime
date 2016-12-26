#创建根据内容改变大小的UILabel
> 概述：根据内容自动调整UILabel的Frame

  研究几种初始化方法，根据内容自动调整UILabel的Frame

> 关键字：

Runtime、Convenience、根据内容自动调整UILabel、Swift 3.0

  
##计算字符串Frame
废话不多说，直接上代码。

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
##几种初始化方法
### 1. 采用Convenience来初始化带调整frame的UIlabel
Convenience构造函数通常用在对系统的类进行构造函数的扩充时使用，在Convenience中调用调整frame方法，[参考： Swift3.0 功能](http://blog.csdn.net/ios_qing/article/details/52812187)：
	
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
### 2. 采用Runtime来初始化UIlabel，再调用调整frame方法
此方法主要用来学习Swift3.0下如何使用黑魔法Runtime。
那在 Swift 中, extension 并不是运行时加载的, 因此也没有加载时候就会被调用的类似 +load 的方法. 事实上，Swift 实现的 load 并不是在 app 运行开始就被调用的。基于这些理由，我们使用另一个类初始化时会被调用的方法来进行交换[参考：Swift3中的Method Swizzling](http://blog.csdn.net/ios_qing/article/details/52812187)：

    open override class func initialize() {
        // Method Swizzling
    }

由于Swift3.0中dispatch_xxxx已经被废弃，因此需要先给DispatchQueue扩展once：

    extension DispatchQueue {
        private static var onceTracker = [String]()
        
        open class func once(token: String, block:() ->     Void) {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }

            if onceTracker.contains(token) {
                return
            }

            onceTracker.append(token)
            block()
        }
    }
然后再来使用 Method Swizzling

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
学习Runtime不是一簇而就，很多时候还要多多摸索，其实很多时候并不需要你去用Runtime，在不得已的情况下才去使用 Runtime。随便修改基础框架或所使用的三方代码会给项目造成很大的影响。请务必要小心哦。[参考：Swift 中的 Runtime](https://segmentfault.com/a/1190000004164803)：

### 3. 系统默认方法创建，再调用调整frame方法
这个就不用多说了，最简单的方法，算在extension里面吧。

> 后记：

通过这个小项目主要学习Extension、Runtime、Convenience等，这样写代码清楚，便于维护   
> 参考：

* [Swift 中的 Runtime](https://segmentfault.com/a/1190000004164803) 
* [Swift3中的Method Swizzling](http://blog.csdn.net/ios_qing/article/details/52812187)
* [Swift3.0 功能](http://blog.csdn.net/ios_qing/article/details/52812187)

>下载[DEMO](https://github.com/JX0829/JXSecurityKeyboard)：
