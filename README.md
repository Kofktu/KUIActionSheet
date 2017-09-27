# KUIActionSheet

![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg)
[![CocoaPods](http://img.shields.io/cocoapods/v/KUIActionSheet.svg?style=flat)](http://cocoapods.org/?q=name%3AKUIActionSheet%20author%3AKofktu)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

> Custom UIActionSheet for Swift

![alt tag](Screenshot/Default.png)
![alt tag](Screenshot/DefaultWithCustomView.png)
![alt tag](Screenshot/CustomTheme.png)
![alt tag](Screenshot/CustomXib.png)

## Requirements

- iOS 8.0+
- Xcode 9.0
- Swift 4.0
- Swift 3.0 ([2.0.4](https://github.com/Kofktu/KUIActionSheet/tree/2.0.4))

## Installation

#### CocoaPods
KUIActionSheet is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "KUIActionSheet"
```

## Usage

#### KUIActionSheet
```Swift 
import KUIActionSheet

let actionSheet = KUIActionSheet.view(parentViewController: self)

actionSheet?.add(customView: UIView<KUIActionSheetItemViewProtocol>)
actionSheet?.add(item: KUIActionSheetItem(title: "Menu1", destructive: false) { [weak self] (item) in
  print(item.title)
})
actionSheet?.show()

```

#### CustomView
```Swift 
class CustomView: UIView, KUIActionSheetItemViewProtocol {
    
    func ... () {
      actionSheet?.dismiss()
    }
}

```

#### CustomTheme
```Swift 
public protocol KUIActionSheetProtocol {
    var backgroundColor: UIColor { get }
    var showAnimationDuration: NSTimeInterval { get }
    var dimissAnimationDuration: NSTimeInterval { get }
    var blurEffectStyle: UIBlurEffectStyle { get }
    var itemTheme: KUIActionSheetItemTheme { get }
}

public protocol KUIActionSheetItemTheme {
    var height: CGFloat { get }
    var font: UIFont { get }
    var titleColor: UIColor { get }
    var destructiveTitleColor: UIColor { get }
}

```

## Authors

Taeun Kim (kofktu), <kofktu@gmail.com>

## License

KUIActionSheet is available under the ```MIT``` license. See the ```LICENSE``` file for more info.
