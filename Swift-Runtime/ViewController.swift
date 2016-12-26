//
//  ViewController.swift
//  Swift-Runtime
//
//  Created by XiaoLai－JX on 16/12/23.
//  Copyright © 2016年 XiaoLai－JX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
//    @IBOutlet weak var JXTextField: JXTextField_RT!

    override func viewDidLoad() {
        super.viewDidLoad()
        let text = UILabel(frame: CGRect(x: 50, y: 200, width: 300, height: 30), maxWidth: nil,str:"我是通过Convenience建立的，long...long...long...long...long...long...long...long...")
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.layer.borderWidth = 1
        self.view.addSubview(text)
        
        let text2 = UILabel(frame: CGRect(x: 50, y: 300, width: 300, height: 30))
        text2.text = "我是通过Swizzling建立的，long...long...long...long...long...long...long...long..."
        text2.getContentSize(maxWidth: nil)
        text2.layer.borderColor = UIColor.lightGray.cgColor
        text2.layer.borderWidth = 1
        self.view.addSubview(text2)
        
        let text3 = UILabel()
        text3.frame = CGRect(x: 50, y: 400, width: 300, height: 30)
        text3.text = "我是通过系统默认建立的，long...long...long...long...long...long...long...long..."
        text3.getContentSize(maxWidth: nil)
        text3.layer.borderColor = UIColor.lightGray.cgColor
        text3.layer.borderWidth = 1
        self.view.addSubview(text3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

