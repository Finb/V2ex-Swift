<h3 align="center">
    <img src="Ji.png" width=220 alt="Ji: a Swift XML/HTML parser" />
</h3>

Ji 戟
=====

[![CI Status](https://travis-ci.org/honghaoz/Ji.svg?branch=master)](https://travis-ci.org/honghaoz/Ji)[![Cocoapods Version](https://img.shields.io/cocoapods/v/Ji.svg?style=flat)](http://cocoapods.org/pods/Ji)[![License](https://img.shields.io/cocoapods/l/Ji.svg?style=flat)](http://cocoapods.org/pods/Ji)[![Platform](https://img.shields.io/cocoapods/p/Ji.svg?style=flat)](http://cocoapods.org/pods/Ji)

Ji (戟) is a Swift wrapper on libxml2 for parsing XML/HTML.

Features
--------

-	[x] Build XML/HTML Tree and Navigate
-	[x] XPath Query Supported
-	[x] Comprehensive Unit Test Coverage
-	[ ] CSS Selector (on going)

Requirements
------------

-	iOS 8.0+ / Mac OS X 10.9+ / watchOS 2.0+ / tvOS 9.0+
-	Xcode 7.0+

Installation
------------

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

To integrate **Ji** into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'Ji', '~> 1.2.0'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

To integrate `Ji` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "honghaoz/Ji" >= 1.2.0
```

### Manually

If you prefer not to use a dependency manager, you can integrate Ji into your project manually.

-	Configure Xcode project:
	-	Open project, select the target, under **General**, in **Linked Frameworks and Libraries**, add `libxml2.2.dylib` and `libxml2.dylib`
	-	Under **Build Settings**, in **Header Search Paths**, add `$(SDKROOT)/usr/include/libxml2`
	-	Under **Build Settings**, in **Other Linker Flags**, add `-lxml2`
-	Import `libxml` headers:
	-	Copy the those import statements:`swift
		#import <libxml/tree.h>
		#import <libxml/parser.h>
		#import <libxml/HTMLtree.h>
		#import <libxml/HTMLparser.h>
		#import <libxml/xpath.h>
		#import <libxml/xpathInternals.h>
		#import <libxml/xmlerror.h>
		` and paste them into your `[Modulename]-Bridging-Header.h`
-	Drag `Ji.swift`, `JiHelper.swift` and `JiNode.swift` in [**Source**](https://github.com/honghaoz/Ji/tree/master/Source) folder into your project.

And that's it!

Usage
-----

> If you are using Cocoapods to integrate Ji. Import Ji first:`swift
> import Ji
> `

-	Init with `NSURL`:

```swift
let jiDoc = Ji(htmlURL: NSURL(string: "http://www.apple.com/support")!)
let titleNode = jiDoc?.xPath("//head/title")?.first
println("title: \(titleNode?.content)") // title: Optional("Official Apple Support")
```

-	Init with `String`:

```swift
let xmlString = "<?xml version='1.0' encoding='UTF-8'?><note><to>Tove</to><from>Jani</from><heading>Reminder</heading><body>Don't forget me this weekend!</body></note>"
let jiDoc = Ji(xmlString: xmlString)
let bodyNode = jiDoc?.rootNode?.firstChildWithName("body")
println("body: \(bodyNode?.content)") // body: Optional("Don\'t forget me this weekend!")
```

-	Init with `NSData`:

```swift
let googleIndexData = NSData(contentsOfURL: NSURL(string: "http://www.google.com")!)
if let googleIndexData = googleIndexData {
	let jiDoc = Ji(htmlData: googleIndexData)!
	let htmlNode = jiDoc.rootNode!
	println("html tagName: \(htmlNode.tagName)") // html tagName: Optional("html")

	let aNodes = jiDoc.xPath("//body//a")
	if let firstANode = aNodes?.first {
		println("first a node tagName: \(firstANode.name)") // first a node tagName: Optional("a")
		let href = firstANode["href"]
		println("first a node href: \(href)") // first a node href: Optional("http://www.google.ca/imghp?hl=en&tab=wi")
	}
} else {
	println("google.com is inaccessible")
}

let 戟文档 = 戟(htmlURL: NSURL(string: "https://cocoapods.org/pods/Ji")!)
let attribution = 戟文档?.xPath("//ul[@class='attribution']")?.first
println("作者(Author): \(attribution?.content)")
```

License
-------

The MIT License (MIT)

Copyright (c) 2015 Honghao Zhang (张宏昊)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
