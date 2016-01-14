# Drawer Controller
[![Version Status](http://img.shields.io/cocoapods/v/DrawerController.png)](http://cocoadocs.org/docsets/DrawerController/1.0.3/) [![license MIT](http://img.shields.io/badge/license-MIT-orange.png)](http://opensource.org/licenses/MIT) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

`DrawerController` is a swift version of the popular `MMDrawerController` by [Mutual Mobile](https://github.com/mutualmobile/MMDrawerController).

Some minor changes in this version include the removal of all < iOS 7.0 related code and the use of spring animations instead of ease-in-ease-out animations. We've also added an animated `BarButtonItem` and plan to enable additional features for regular horizontal size classes (i.e. iPad and iPhone 6 Plus in landscape).

This is currently a work in progress and has not been thoroughly tested. Use at your own risk.

## Installation


#### [CocoaPods](http://cocoapods.org)

````ruby
platform :ios, '8.0'
use_frameworks!

pod 'DrawerController', '~> 1.0'
````

#### [Carthage](https://github.com/Carthage/Carthage)

````bash
github "sascha/DrawerController"
````

---
## Credit

Originally designed and developed by the fine folks at [Mutual Mobile](http://mutualmobile.com).

Swift version by

* [Sascha Schwabbauer](http://twitter.com/_saschas)
* [Malte Baumann](http://twitter.com/codingdivision)

---
## License

`DrawerController` is available under the MIT license. See the LICENSE file for more info.
