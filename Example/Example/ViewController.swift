//
//  ViewController.swift
//  Example
//
//  Created by kofktu on 2016. 7. 8..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit
import KUIActionSheet

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onPressed(sender: UIButton) {
        let actionSheet = KUIActionSheet.view(parentViewController: self)
        
        let headerView = HeaderView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(view.frame), 50.0))
        headerView.backgroundColor = UIColor.redColor()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50.0))
        
        actionSheet?.add(customView: headerView)
        actionSheet?.add(item: KUIActionSheetItem(title: "메뉴1", destructive: false) { [weak self] (item) in
            print(item.title)
        })
        actionSheet?.add(item: KUIActionSheetItem(title: "메뉴2", destructive: false) { [weak self] (item) in
            print(item.title)
        })
        actionSheet?.add(item: KUIActionSheetItem(title: "메뉴3", destructive: false) { [weak self] (item) in
            print(item.title)
        })
        actionSheet?.show()
    }
    
}

class HeaderView: UIView, KUIActionSheetItemViewProtocol {
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        actionSheet?.dismiss()
    }
}

