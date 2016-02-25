# INSImageView
[![Version](https://img.shields.io/cocoapods/v/INSImageView.svg?style=flat)](http://cocoapods.org/pods/INSImageView)
[![License](https://img.shields.io/cocoapods/l/INSImageView.svg?style=flat)](http://cocoapods.org/pods/INSImageView)
[![Platform](https://img.shields.io/cocoapods/p/INSImageView.svg?style=flat)](http://cocoapods.org/pods/INSImageView)

## Description
A UIImageView that allows for animations between UIViewContentModes through the use of UIView block-based animations e.g. UIView.animateWithDuration...

![Animation Image](https://github.com/instilio/INSImageView/raw/master/Example/ExampleAnimation.gif)

## Compatibility
Tested with iOS8 and iOS9 using Swift

## Usage
```swift
let imageView = INSImageView(...)
imageView.contentMode = .ScaleAspectFit

UIView.animateWithDuration(1,
    animations: {
      self.imageView.contentMode = .ScaleAspectFill
    }
)
```

## Caveat
Due to the way INSImageView is implemented, the `image` and `highlightedImage` property getters need to be NOOPed. If you're wishing to get the original image please use `originalImage` or `originalHighlightedImage` respectively.
```swift
let image = imageView.originalImage
let highlightedImage = imageView.originalHighlightedImage
```

## Installation

INSImageView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "INSImageView"
```

## TODO
- [ ] Tests (including creating INSImageView from code/storyboard)

## Contact
Patrick, patbdev@gmail.com

## License
INSImageView is available under the MIT license. See the LICENSE file for more info.
