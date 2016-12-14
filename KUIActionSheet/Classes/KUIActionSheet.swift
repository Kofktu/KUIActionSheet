//
//  KUIActionSheet.swift
//  KUIActionSheet
//
//  Created by kofktu on 2016. 7. 8..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

public protocol KUIActionSheetProtocol {
    var backgroundColor: UIColor { get }
    var showAnimationDuration: TimeInterval { get }
    var dimissAnimationDuration: TimeInterval { get }
    var blurEffectStyle: UIBlurEffectStyle { get }
    var itemTheme: KUIActionSheetItemTheme { get }
}

public struct KUIActionSheetDefault: KUIActionSheetProtocol {
    public var backgroundColor: UIColor {
        return UIColor(white: 0.0, alpha: 0.4)
    }
    
    public var showAnimationDuration: TimeInterval {
        return 0.25
    }
    
    public var dimissAnimationDuration: TimeInterval {
        return 0.15
    }
    
    public var blurEffectStyle: UIBlurEffectStyle {
        return .extraLight
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
        return UIFont.systemFont(ofSize: 20.0)
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
            responder = responder?.next
        }
        return nil
    }
}

public protocol KUIActionSheetNibLoadableView: class {
    static var nibName: String { get }
}

extension KUIActionSheetNibLoadableView where Self: KUIActionSheet {
    public static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public static func viewWithNib(parentViewController viewController: UIViewController, theme: KUIActionSheetProtocol = KUIActionSheetDefault()) -> KUIActionSheetNibLoadableView? {
        return viewWithNibName(nibFileName: nibName, parentViewController: viewController, theme: theme)
    }
    
    public static func viewWithNibName(nibFileName: String,  parentViewController viewController: UIViewController, theme: KUIActionSheetProtocol = KUIActionSheetDefault()) -> KUIActionSheetNibLoadableView? {
        guard let views = Bundle(for: self).loadNibNamed(nibFileName, owner: nil, options: nil) else { return nil }
        
        for view in views {
            if let view = view as? Self {
                view.theme = theme
                view.parentViewController = viewController
                return view
            }
        }
        return nil
    }
}

private extension UIViewController {
    
    var rootViewController: UIViewController {
        var rootViewController: UIViewController = self
        while let parentViewController = rootViewController.parent {
            rootViewController = parentViewController
        }
        return rootViewController
    }
    
}

open class KUIActionSheet: UIView {

    @IBOutlet public weak var containerView: UIView!
    @IBOutlet public weak var cancelButton: UIButton!
    @IBOutlet public weak var cancelButtonBottom: NSLayoutConstraint!
    open var theme: KUIActionSheetProtocol!
    open var tapToDismiss: Bool = true
    open fileprivate(set) var parentViewController: UIViewController!
    
    fileprivate var showing: Bool = false
    fileprivate var animating: Bool = false
    fileprivate var lastViewBottom: NSLayoutConstraint?
    
    public class func view(parentViewController viewController: UIViewController, theme: KUIActionSheetProtocol = KUIActionSheetDefault()) -> KUIActionSheet? {
        guard let views = Bundle(for: self).loadNibNamed("KUIActionSheet", owner: nil, options: nil) else { return nil }
        
        for view in views {
            if let view = view as? KUIActionSheet {
                view.theme = theme
                view.parentViewController = viewController
                return view
            }
        }
        
        return nil
    }
    
    convenience override init(frame: CGRect) {
        fatalError("not support")
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 8.0
        cancelButton.layer.cornerRadius = 8.0
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        addGestureRecognizer(singleTap)
    }
    
    open func show(viewController: UIViewController? = nil, completion: ((Bool) -> Void)? = nil) {
        guard !showing else {
            completion?(false)
            return
        }
        
        let targetViewController: UIViewController = viewController ?? parentViewController.rootViewController
        
        showing = true
        animating = true
        backgroundColor = theme.backgroundColor
        targetViewController.view.endEditing(true)
        
        translatesAutoresizingMaskIntoConstraints = false
        targetViewController.view.addSubview(self)
        targetViewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]))
        targetViewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self]))
        
        let initialBottomSpace = cancelButtonBottom.constant
        
        cancelButtonBottom.constant = -targetViewController.view.frame.height
        layoutIfNeeded()
        
        cancelButtonBottom.constant = initialBottomSpace
        
        UIView.animate(withDuration: theme.showAnimationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: 7 << 16), animations: {
            self.layoutIfNeeded()
        }) { (finished) in
            completion?(finished)
            self.animating = false
        }
    }
    
    open func dismiss(completion: ((Bool) -> Void)? = nil) {
        guard showing else {
            completion?(false)
            return
        }
        
        showing = false
        animating = true
        isUserInteractionEnabled = false
        cancelButtonBottom.constant = -parentViewController.rootViewController.view.frame.height
        
        UIView.animate(withDuration: theme.dimissAnimationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: 7 << 16), animations: {
            self.backgroundColor = self.theme.backgroundColor.withAlphaComponent(0.0)
            self.layoutIfNeeded()
        }) { (finished) in
            completion?(true)
            self.animating = false
            self.removeFromSuperview()
        }
    }
    
    open func add(customView view: UIView?) {
        if view?.translatesAutoresizingMaskIntoConstraints ?? false {
            view?.translatesAutoresizingMaskIntoConstraints = false
            
            if let view = view {
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: view.frame.height))
            }
        }
        
        add(view: view)
    }
    
    open func add(item: KUIActionSheetItem) {
        let itemTheme = theme.itemTheme
        
        let button = KUIActionSheetItemButton.button(item)
        button.titleLabel?.font = itemTheme.font
        button.setTitleColor(item.destructive ? itemTheme.destructiveTitleColor : itemTheme.titleColor, for: [])
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: itemTheme.height))
        add(view: button)
    }
    
    fileprivate func add(view: UIView?) {
        guard let view = view else { return }
        
        let verticalGap = 1.0 / UIScreen.main.scale
        let lastView = containerView.subviews.last
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: theme.blurEffectStyle))
        visualEffectView.contentView.backgroundColor = UIColor.clear
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(view)
        visualEffectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        visualEffectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        
        containerView.addSubview(visualEffectView)
        
        if let lastViewBottom = lastViewBottom {
            containerView.removeConstraint(lastViewBottom)
            self.lastViewBottom = nil
        }
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": visualEffectView]))
        
        if let lastView = lastView {
            containerView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: verticalGap))
        } else {
            containerView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0))
        }
        
        lastViewBottom = NSLayoutConstraint(item: visualEffectView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        containerView.addConstraint(lastViewBottom!)
    }
    
    internal func singleTap(_ gesture: UITapGestureRecognizer) {
        guard !animating else { return }
        guard gesture.location(in: self).y < containerView.frame.origin.y && tapToDismiss else { return }
        dismiss()
    }
    
    @IBAction func onClose(sender: UIButton) {
        dismiss()
    }
}

private class KUIActionSheetItemButton: UIButton, KUIActionSheetItemViewProtocol {
    
    private var item: KUIActionSheetItem! {
        willSet {
            removeTarget(self, action: #selector(onPressed(_:)), for: .touchUpInside)
        }
        didSet {
            setTitle(item.title, for: [])
            addTarget(self, action: #selector(onPressed(_:)), for: .touchUpInside)
        }
    }
    
    class func button(_ item: KUIActionSheetItem) -> KUIActionSheetItemButton {
        let button = KUIActionSheetItemButton(type: .custom)
        button.item = item
        return button
    }
    
    @objc func onPressed(_ sender: UIButton) {
        item.handler?(item)
        actionSheet?.dismiss()
    }
}
