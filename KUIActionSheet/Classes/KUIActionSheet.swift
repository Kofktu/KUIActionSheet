//
//  KUIActionSheet.swift
//  KUIActionSheet
//
//  Created by kofktu on 2016. 7. 8..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

public protocol KUIActionSheetProtocol {
    var animationDuration: NSTimeInterval { get }
    var blurEffectStyle: UIBlurEffectStyle { get }
    var itemTheme: KUIActionSheetItemTheme { get }
}

public struct KUIActionSheetDefault: KUIActionSheetProtocol {
    public var animationDuration: NSTimeInterval {
        return 0.25
    }
    
    public var blurEffectStyle: UIBlurEffectStyle {
        return .ExtraLight
    }
    
    public var itemTheme: KUIActionSheetItemTheme {
        return KUIActionSheetItemDefaultTheme()
    }
}

public protocol KUIActionSheetItemTheme {
    var height: CGFloat { get }
    var font: UIFont { get }
    var titleColor: UIColor { get }
    var destructiveTitleColor: UIColor { get }
}

public struct KUIActionSheetItemDefaultTheme: KUIActionSheetItemTheme {
    public var height: CGFloat {
        return 57.0
    }
    
    public var font: UIFont {
        return UIFont.systemFontOfSize(20.0)
    }
    
    public var titleColor: UIColor {
        return UIColor(red: 0/255.0, green: 118/255.0, blue: 255/255.0, alpha: 1.0)
    }
    
    public var destructiveTitleColor: UIColor {
        return UIColor(red: 255/255.0, green: 69/255.0, blue: 57/255.0, alpha: 1.0)
    }
}

public struct KUIActionSheetItem {
    public let title: String
    public let destructive: Bool
    public let handler: ((KUIActionSheetItem) -> Void)?
    
    public init(
        title: String,
        destructive: Bool = false,
        handler: ((KUIActionSheetItem) -> Void)?) {
        self.title = title
        self.destructive = destructive
        self.handler = handler
    }
}

public protocol KUIActionSheetItemViewProtocol {}
extension KUIActionSheetItemViewProtocol where Self: UIView {
    public var actionSheet: KUIActionSheet? {
        var responder: UIResponder? = self
        while responder != nil {
            if let sheet = responder as? KUIActionSheet {
                return sheet
            }
            responder = responder?.nextResponder()
        }
        return nil
    }
}

public class KUIActionSheet: UIView {

    @IBOutlet public weak var containerView: UIView!
    @IBOutlet public weak var cancelButton: UIButton!
    @IBOutlet public weak var cancelButtonBottom: NSLayoutConstraint!
    public var theme: KUIActionSheetProtocol!
    public var tapToDismiss: Bool = true
    
    private var showing: Bool = false
    private var parentViewController: UIViewController!
    private var lastViewBottom: NSLayoutConstraint?
    
    class public func view(parentViewController viewController: UIViewController, theme: KUIActionSheetProtocol = KUIActionSheetDefault()) -> KUIActionSheet? {
        let views = NSBundle(forClass: self).loadNibNamed("KUIActionSheet", owner: nil, options: nil)
        for view in views {
            if let view = view as? KUIActionSheet {
                view.theme = theme
                view.parentViewController = viewController
                return view
            }
        }
        return nil
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 8.0
        cancelButton.layer.cornerRadius = 8.0
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard let location = touches.first?.locationInView(self) where tapToDismiss else { return }
        
        if location.y < CGRectGetMinY(containerView.frame) {
            dismiss()
        }
    }
    
    public func show(completion: ((Bool) -> Void)? = nil) {
        guard !showing else {
            completion?(false)
            return
        }
        
        showing = true
        parentViewController.view.endEditing(true)
        
        translatesAutoresizingMaskIntoConstraints = false
        parentViewController.view.addSubview(self)
        parentViewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]))
        parentViewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]))
        
        let initialBottomSpace = cancelButtonBottom.constant
        
        cancelButtonBottom.constant = -CGRectGetHeight(parentViewController.view.frame)
        layoutIfNeeded()
        
        cancelButtonBottom.constant = initialBottomSpace
        
        UIView.animateWithDuration(theme.animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: 7 << 16), animations: { 
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    public func dismiss(completion: ((Bool) -> Void)? = nil) {
        guard showing else {
            completion?(false)
            return
        }
        
        showing = false
        cancelButtonBottom.constant = -CGRectGetHeight(parentViewController.view.frame)
        
        UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseOut, animations: {
            self.layoutIfNeeded()
        }) { (finished) in
            completion?(true)
            self.removeFromSuperview()
        }
    }
    
    public func add(customView view: UIView?) {
        add(view: view)
    }
    
    public func add(item item: KUIActionSheetItem) {
        let itemTheme = theme.itemTheme
        
        let button = KUIActionSheetItemButton.button(item)
        button.setTitleColor(item.destructive ? itemTheme.destructiveTitleColor : itemTheme.titleColor, forState: .Normal)
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: itemTheme.height))
        add(view: button)
    }
    
    private func add(view view: UIView?) {
        guard let view = view else { return }
        
        let verticalGap = 1.0 / UIScreen.mainScreen().scale
        let lastView = containerView.subviews.last
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: theme.blurEffectStyle))
        visualEffectView.contentView.backgroundColor = UIColor.clearColor()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(view)
        visualEffectView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        visualEffectView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        
        containerView.addSubview(visualEffectView)
        
        if let lastViewBottom = lastViewBottom {
            containerView.removeConstraint(lastViewBottom)
            self.lastViewBottom = nil
        }
        
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": visualEffectView]))
        
        if let lastView = lastView {
            containerView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .Top, relatedBy: .Equal, toItem: lastView, attribute: .Bottom, multiplier: 1.0, constant: verticalGap))
        } else {
            containerView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 0.0))
        }
        
        lastViewBottom = NSLayoutConstraint(item: visualEffectView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        containerView.addConstraint(lastViewBottom!)
    }
    
    @IBAction func onClose(sender: UIButton) {
        dismiss()
    }
}

private class KUIActionSheetItemButton: UIButton, KUIActionSheetItemViewProtocol {
    
    private var item: KUIActionSheetItem! {
        willSet {
            removeTarget(self, action: #selector(onPressed(_:)), forControlEvents: .TouchUpInside)
        }
        didSet {
            setTitle(item.title, forState: .Normal)
            addTarget(self, action: #selector(onPressed(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    class func button(item: KUIActionSheetItem) -> KUIActionSheetItemButton {
        let button = KUIActionSheetItemButton(type: .Custom)
        button.item = item
        return button
    }
    
    @objc func onPressed(sender: UIButton) {
        item.handler?(item)
        actionSheet?.dismiss()
    }
}
