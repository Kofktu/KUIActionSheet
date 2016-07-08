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

