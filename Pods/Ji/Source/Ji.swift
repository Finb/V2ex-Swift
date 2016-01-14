//
//  Ji.swift
//  Ji
//
//  Created by Honghao Zhang on 2015-07-21.
//  Copyright (c) 2015 Honghao Zhang (张宏昊)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public typealias 戟 = Ji

/// Ji document
public class Ji {
	/// A flag specifies whether the data is XML or not.
	internal var isXML: Bool = true
	/// The XML/HTML data.
	private(set) public var data: NSData?
	/// The encoding used by in this document.
	private(set) public var encoding: NSStringEncoding = NSUTF8StringEncoding
	
	public typealias htmlDocPtr = xmlDocPtr
	/// The xmlDocPtr for this document
	private(set) public var xmlDoc: xmlDocPtr = nil
	/// Alias for xmlDoc
	private(set) public var htmlDoc: htmlDocPtr {
		get { return xmlDoc }
		set { xmlDoc = newValue }
	}
	
	
	
	// MARK: - Init
	
	/**
	Initializes a Ji document object with the supplied data, encoding and boolean flag.
	
	- parameter data:     The XML/HTML data.
	- parameter encoding: The encoding used by data.
	- parameter isXML:    Whether this is a XML data, true for XML, false for HTML.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public required init?(data: NSData?, encoding: NSStringEncoding, isXML: Bool) {
		if let data = data where data.length > 0 {
			self.isXML = isXML
			self.data = data
			self.encoding = encoding
			
			let cBuffer = UnsafePointer<CChar>(data.bytes)
			let cSize = CInt(data.length)
			let cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding)
			let cfEncodingAsString: CFStringRef = CFStringConvertEncodingToIANACharSetName(cfEncoding)
			let cEncoding: UnsafePointer<CChar> = CFStringGetCStringPtr(cfEncodingAsString, 0)
			
			if isXML {
				let options = CInt(XML_PARSE_RECOVER.rawValue)
				xmlDoc = xmlReadMemory(cBuffer, cSize, nil, cEncoding, options)
			} else {
				let options = CInt(HTML_PARSE_RECOVER.rawValue | HTML_PARSE_NOWARNING.rawValue | HTML_PARSE_NOERROR.rawValue)
				htmlDoc = htmlReadMemory(cBuffer, cSize, nil, cEncoding, options)
			}
			if xmlDoc == nil { return nil }
		} else {
			return nil
		}
	}
	
	/**
	Initializes a Ji document object with the supplied data and boolean flag, using NSUTF8StringEncoding.
	
	- parameter data:  The XML/HTML data.
	- parameter isXML: Whether this is a XML data, true for XML, false for HTML.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(data: NSData?, isXML: Bool) {
		self.init(data: data, encoding: NSUTF8StringEncoding, isXML: isXML)
	}
	
	
	
	// MARK: - Data Init
	
	/**
	Initializes a Ji document object with the supplied XML data and encoding.
	
	- parameter xmlData:  The XML data.
	- parameter encoding: The encoding used by data.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(xmlData: NSData, encoding: NSStringEncoding) {
		self.init(data: xmlData, encoding: encoding, isXML: true)
	}
	
	/**
	Initializes a Ji document object with the supplied XML data, using NSUTF8StringEncoding.
	
	- parameter xmlData: The XML data.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(xmlData: NSData) {
		self.init(data: xmlData, isXML: true)
	}
	
	/**
	Initializes a Ji document object with the supplied HTML data and encoding.
	
	- parameter htmlData: The HTML data.
	- parameter encoding: The encoding used by data.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(htmlData: NSData, encoding: NSStringEncoding) {
		self.init(data: htmlData, encoding: encoding, isXML: false)
	}
	
	/**
	Initializes a Ji document object with the supplied HTML data, using NSUTF8StringEncoding.
	
	- parameter htmlData: The HTML data.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(htmlData: NSData) {
		self.init(data: htmlData, isXML: false)
	}
	
	
	
	// MARK: - URL Init
	
	/**
	Initializes a Ji document object with the contents of supplied URL, encoding and boolean flag.
	
	- parameter url:      The URL from which to read data.
	- parameter encoding: The encoding used by data.
	- parameter isXML:    Whether this is a XML data URL, true for XML, false for HTML.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(contentsOfURL url: NSURL, encoding: NSStringEncoding, isXML: Bool) {
		let data = NSData(contentsOfURL: url)
		self.init(data: data, encoding: encoding, isXML: isXML)
	}
	
	/**
	Initializes a Ji document object with the contents of supplied URL, and boolean flag, using NSUTF8StringEncoding.
	
	- parameter url:   The URL from which to read data.
	- parameter isXML: Whether this is a XML data URL, true for XML, false for HTML.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(contentsOfURL url: NSURL, isXML: Bool) {
		self.init(contentsOfURL: url, encoding: NSUTF8StringEncoding, isXML: isXML)
	}
	
	/**
	Initializes a Ji document object with the contents of supplied XML URL, using NSUTF8StringEncoding.
	
	- parameter xmlURL: The XML URL from which to read data.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(xmlURL: NSURL) {
		self.init(contentsOfURL: xmlURL, isXML: true)
	}
	
	/**
	Initializes a Ji document object with the contents of supplied HTML URL, using NSUTF8StringEncoding.
	
	- parameter htmlURL: The HTML URL from which to read data.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(htmlURL: NSURL) {
		self.init(contentsOfURL: htmlURL, isXML: false)
	}
	
	
	
	// MARK:  - String Init
	
	/**
	Initializes a Ji document object with a XML string and it's encoding.
	
	- parameter xmlString: XML string.
	- parameter encoding:  The encoding used by xmlString.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(xmlString: String, encoding: NSStringEncoding) {
		let data = xmlString.dataUsingEncoding(encoding, allowLossyConversion: false)
		self.init(data: data, encoding: encoding, isXML: true)
	}
	
	/**
	Initializes a Ji document object with a HTML string and it's encoding.
	
	- parameter htmlString: HTML string.
	- parameter encoding:   The encoding used by htmlString.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(htmlString: String, encoding: NSStringEncoding) {
		let data = htmlString.dataUsingEncoding(encoding, allowLossyConversion: false)
		self.init(data: data, encoding: encoding, isXML: false)
	}
	
	/**
	Initializes a Ji document object with a XML string, using NSUTF8StringEncoding.
	
	- parameter xmlString: XML string.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(xmlString: String) {
		let data = xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
		self.init(data: data, isXML: true)
	}
	
	/**
	Initializes a Ji document object with a HTML string, using NSUTF8StringEncoding.
	
	- parameter htmlString: HTML string.
	
	- returns: The initialized Ji document object or nil if the object could not be initialized.
	*/
	public convenience init?(htmlString: String) {
		let data = htmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
		self.init(data: data, isXML: false)
	}
	
	
	
	// MARK: - Deinit
	deinit {
		xmlFreeDoc(xmlDoc)
	}
	
	
	
	// MARK: - Public methods
	
	/// Root node of this Ji document object.
	public lazy var rootNode: JiNode? = {
		let rootNodePointer = xmlDocGetRootElement(self.xmlDoc)
		if rootNodePointer == nil {
			return nil
		} else {
			return JiNode(xmlNode: rootNodePointer, jiDocument: self)
		}
	}()
	
	/**
	Perform XPath query on this document.
	
	- parameter xPath: XPath query string.
	
	- returns: An array of JiNode or nil if rootNode is nil. An empty array will be returned if XPath matches no nodes.
	*/
	public func xPath(xPath: String) -> [JiNode]? {
		return self.rootNode?.xPath(xPath)
	}
}



// MARK: - Equatable
extension Ji: Equatable { }
public func ==(lhs: Ji, rhs: Ji) -> Bool {
	return lhs.xmlDoc == rhs.xmlDoc
}

// MARK: - CustomStringConvertible
extension Ji: CustomStringConvertible {
	public var description: String {
		return rootNode?.rawContent ?? "nil"
	}
}
