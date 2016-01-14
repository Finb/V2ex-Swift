//
//  JiNode.swift
//  Ji
//
//  Created by Honghao Zhang on 2015-07-20.
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

public typealias 戟节点 = JiNode

/**
JiNode types, these match element types in tree.h

*/
public enum JiNodeType: Int {
	case Element = 1
	case Attribute = 2
	case Text = 3
	case CDataSection = 4
	case EntityRef = 5
	case Entity = 6
	case Pi = 7
	case Comment = 8
	case Document = 9
	case DocumentType = 10
	case DocumentFrag = 11
	case Notation = 12
	case HtmlDocument = 13
	case DTD = 14
	case ElementDecl = 15
	case AttributeDecl = 16
	case EntityDecl = 17
	case NamespaceDecl = 18
	case XIncludeStart = 19
	case XIncludeEnd = 20
	case DocbDocument = 21
}

/// Ji node
public class JiNode {
	/// The xmlNodePtr for this node.
	public let xmlNode: xmlNodePtr
	/// The Ji document contians this node.
	public unowned let document: Ji
	/// Node type.
	public let type: JiNodeType
	
	/// A helper flag to get whether keepTextNode has been changed.
	private var _keepTextNodePrevious = false
	/// Whether should remove text node. By default, keepTextNode is false.
	public var keepTextNode = false
	
	/**
	Initializes a JiNode object with the supplied xmlNodePtr, Ji document and keepTextNode boolean flag.
	
	- parameter xmlNode:      The xmlNodePtr for a node.
	- parameter jiDocument:   The Ji document contains this node.
	- parameter keepTextNode: Whether it should keep text node, by default, it's false.
	
	- returns: The initialized JiNode object.
	*/
	init(xmlNode: xmlNodePtr, jiDocument: Ji, keepTextNode: Bool = false) {
		self.xmlNode = xmlNode
		document = jiDocument
		type = JiNodeType(rawValue: Int(xmlNode.memory.type.rawValue))!
		self.keepTextNode = keepTextNode
	}
	
	/// The tag name of this node.
	public var tag: String? { return name }
	
	/// The tag name of this node.
	public var tagName: String? { return name }
	
	/// The tag name of this node.
	public lazy var name: String? = {
		return String.fromXmlChar(self.xmlNode.memory.name)
	}()
	
	/// Helper property for avoiding unneeded calculations.
	private var _children: [JiNode] = []
	/// A helper flag for avoiding unneeded calculations.
	private var _childrenHasBeenCalculated = false
	/// The children of this node. keepTextNode property affects the results
	public var children: [JiNode] {
		if _childrenHasBeenCalculated && keepTextNode == _keepTextNodePrevious {
			return _children
		} else {
			_children = [JiNode]()
			
			for var childNodePointer = xmlNode.memory.children;
				childNodePointer != nil;
				childNodePointer = childNodePointer.memory.next
			{
				if keepTextNode || xmlNodeIsText(childNodePointer) == 0 {
					let childNode = JiNode(xmlNode: childNodePointer, jiDocument: document, keepTextNode: keepTextNode)
					_children.append(childNode)
				}
			}
			_childrenHasBeenCalculated = true
			_keepTextNodePrevious = keepTextNode
			return _children
		}
	}
	
	/// The first child of this node, nil if the node has no child.
	public var firstChild: JiNode? {
		var first = xmlNode.memory.children
		if first == nil { return nil }
		if keepTextNode {
			return JiNode(xmlNode: first, jiDocument: document, keepTextNode: keepTextNode)
		} else {
			while xmlNodeIsText(first) != 0 {
				first = first.memory.next
				if first == nil { return nil }
			}
			return JiNode(xmlNode: first, jiDocument: document, keepTextNode: keepTextNode)
		}
	}
	
	/// The last child of this node, nil if the node has no child.
	public var lastChild: JiNode? {
		var last = xmlNode.memory.last
		if last == nil { return nil }
		if keepTextNode {
			return JiNode(xmlNode: last, jiDocument: document, keepTextNode: keepTextNode)
		} else {
			while xmlNodeIsText(last) != 0 {
				last = last.memory.prev
				if last == nil { return nil }
			}
			return JiNode(xmlNode: last, jiDocument: document, keepTextNode: keepTextNode)
		}
	}
	
	/// Whether this node has children.
	public var hasChildren: Bool {
		return firstChild != nil
	}
	
	/// The parent of this node.
	public lazy var parent: JiNode? = {
		if self.xmlNode.memory.parent == nil { return nil }
		return JiNode(xmlNode: self.xmlNode.memory.parent, jiDocument: self.document)
	}()
	
	/// The next sibling of this node.
	public var nextSibling: JiNode? {
		var next = xmlNode.memory.next
		if next == nil { return nil }
		if keepTextNode {
			return JiNode(xmlNode: next, jiDocument: document, keepTextNode: keepTextNode)
		} else {
			while xmlNodeIsText(next) != 0 {
				next = next.memory.next
				if next == nil { return nil }
			}
			return JiNode(xmlNode: next, jiDocument: document, keepTextNode: keepTextNode)
		}
	}
	
	/// The previous sibling of this node.
	public var previousSibling: JiNode? {
		var prev = xmlNode.memory.prev
		if prev == nil { return nil }
		if keepTextNode {
			return JiNode(xmlNode: prev, jiDocument: document, keepTextNode: keepTextNode)
		} else {
			while xmlNodeIsText(prev) != 0 {
				prev = prev.memory.prev
				if prev == nil { return nil }
			}
			return JiNode(xmlNode: prev, jiDocument: document, keepTextNode: keepTextNode)
		}
	}
	
	/// Raw content of this node. Children, tags are also included.
	public lazy var rawContent: String? = {
		let buffer = xmlBufferCreate()
		if self.document.isXML {
			xmlNodeDump(buffer, self.document.xmlDoc, self.xmlNode, 0, 0)
		} else {
			htmlNodeDump(buffer, self.document.htmlDoc, self.xmlNode)
		}
		
		let result = String.fromXmlChar(buffer.memory.content)
		xmlBufferFree(buffer)
		return result
	}()
	
	/// Content of this node. Tags are removed, leading/trailing white spaces, new lines are kept.
	public lazy var content: String? = {
		let contentChars = xmlNodeGetContent(self.xmlNode)
		if contentChars == nil { return nil }
		let contentString = String.fromXmlChar(contentChars)
		free(contentChars)
		return contentString
	}()
	
	/// Raw value of this node. Leading/trailing white spaces, new lines are kept.
	public lazy var value: String? = {
		let valueChars = xmlNodeListGetString(self.document.xmlDoc, self.xmlNode.memory.children, 1)
		if valueChars == nil { return nil }
		let valueString = String.fromXmlChar(valueChars)
		free(valueChars)
		return valueString
	}()
	
	/**
	Get attribute value with key.
	
	- parameter key: An attribute key string.
	
	- returns: The attribute value for the key.
	*/
	public subscript(key: String) -> String? {
		get {
			for var attribute: xmlAttrPtr = self.xmlNode.memory.properties; attribute != nil; attribute = attribute.memory.next {
				if key == String.fromXmlChar(attribute.memory.name) {
					let contentChars = xmlNodeGetContent(attribute.memory.children)
					if contentChars == nil { return nil }
					let contentString = String.fromXmlChar(contentChars)
					free(contentChars)
					return contentString
				}
			}
			return nil
		}
	}
	
	/// The attributes dictionary of this node.
	public lazy var attributes: [String: String] = {
		var result = [String: String]()
		for var attribute: xmlAttrPtr = self.xmlNode.memory.properties;
			attribute != nil;
			attribute = attribute.memory.next
		{
			let key = String.fromXmlChar(attribute.memory.name)
			assert(key != nil, "key doesn't exist")
			let valueChars = xmlNodeGetContent(attribute.memory.children)
			var value: String? = ""
			if valueChars != nil {
				value = String.fromXmlChar(valueChars)
				assert(value != nil, "value doesn't exist")
			}
			free(valueChars)
			
			result[key!] = value!
		}
		return result
	}()
	
	
	
	// MARK: - XPath query
	
	/**
	Perform XPath query on this node.
	
	- parameter xPath: XPath query string.
	
	- returns: An array of JiNode, an empty array will be returned if XPath matches no nodes.
	*/
	public func xPath(xPath: String) -> [JiNode] {
		let xPathContext = xmlXPathNewContext(self.document.xmlDoc)
		if xPathContext == nil {
			// Unable to create XPath context.
			return []
		}
		
		xPathContext.memory.node = self.xmlNode
		
		let xPathObject = xmlXPathEvalExpression(UnsafePointer<xmlChar>(xPath.cStringUsingEncoding(NSUTF8StringEncoding)!), xPathContext)
		xmlXPathFreeContext(xPathContext)
		if xPathObject == nil {
			// Unable to evaluate XPath.
			return []
		}
		
		let nodeSet = xPathObject.memory.nodesetval
		if nodeSet == nil || nodeSet.memory.nodeNr == 0 || nodeSet.memory.nodeTab == nil {
			// NodeSet is nil.
            xmlXPathFreeObject(xPathObject)
			return []
		}
		
		var resultNodes = [JiNode]()
		for i in 0 ..< Int(nodeSet.memory.nodeNr) {
			let jiNode = JiNode(xmlNode: nodeSet.memory.nodeTab[i], jiDocument: self.document, keepTextNode: keepTextNode)
			resultNodes.append(jiNode)
		}
		
		xmlXPathFreeObject(xPathObject)
		
		return resultNodes
	}
	
	
	
	// MARK: - Handy search methods: Children
	
	/**
	Find the first child with the tag name of this node.
	
	- parameter name: A tag name string.
	
	- returns: The JiNode object found or nil if it doesn't exist.
	*/
	public func firstChildWithName(name: String) -> JiNode? {
		var node = firstChild
		while (node != nil) {
			if node!.name == name {
				return node
			}
			node = node?.nextSibling
		}
		return nil
	}
	
	/**
	Find the children with the tag name of this node.
	
	- parameter name: A tag name string.
	
	- returns: An array of JiNode.
	*/
	public func childrenWithName(name: String) -> [JiNode] {
		return children.filter { $0.name == name }
	}
	
	/**
	Find the first child with the attribute name and value of this node.
	
	- parameter attributeName:  An attribute name.
	- parameter attributeValue: The attribute value for the attribute name.
	
	- returns: The JiNode object found or nil if it doesn't exist.
	*/
	public func firstChildWithAttributeName(attributeName: String, attributeValue: String) -> JiNode? {
		var node = firstChild
		while (node != nil) {
			if let value = node![attributeName] where value == attributeValue {
				return node
			}
			node = node?.nextSibling
		}
		return nil
	}
	
	/**
	Find the children with the attribute name and value of this node.
	
	- parameter attributeName:  An attribute name.
	- parameter attributeValue: The attribute value for the attribute name.
	
	- returns: An array of JiNode.
	*/
	public func childrenWithAttributeName(attributeName: String, attributeValue: String) -> [JiNode] {
		return children.filter { $0.attributes[attributeName] == attributeValue }
	}
	
	
	
	// MARK: - Handy search methods: Descendants
	
	/**
	Find the first descendant with the tag name of this node.
	
	- parameter name: A tag name string.
	
	- returns: The JiNode object found or nil if it doesn't exist.
	*/
	public func firstDescendantWithName(name: String) -> JiNode? {
		return firstDescendantWithName(name, node: self)
	}
	
	
	/**
	Helper method: Find the first descendant with the tag name of the node provided.
	
	- parameter name: A tag name string.
	- parameter node: The node from which to find.
	
	- returns: The JiNode object found or nil if it doesn't exist.
	*/
	private func firstDescendantWithName(name: String, node: JiNode) -> JiNode? {
		if !node.hasChildren {
			return nil
		}
		
		for child in node {
			if child.name == name {
				return child
			}
			if let nodeFound = firstDescendantWithName(name, node: child) {
				return nodeFound
			}
		}
		return nil
	}
	
	/**
	Find the descendant with the tag name of this node.
	
	- parameter name: A tag name string.
	
	- returns: An array of JiNode.
	*/
	public func descendantsWithName(name: String) -> [JiNode] {
		return descendantsWithName(name, node: self)
	}
	
	/**
	Helper method: Find the descendant with the tag name of the node provided.
	
	- parameter name: A tag name string.
	- parameter node: The node from which to find.
	
	- returns: An array of JiNode.
	*/
	private func descendantsWithName(name: String, node: JiNode) -> [JiNode] {
		if !node.hasChildren {
			return []
		}
		
		var results = [JiNode]()
		for child in node {
			if child.name == name {
				results.append(child)
			}
			results.appendContentsOf(descendantsWithName(name, node: child))
		}
		return results
	}
	
	/**
	Find the first descendant with the attribute name and value of this node.
	
	- parameter attributeName:  An attribute name.
	- parameter attributeValue: The attribute value for the attribute name.
	
	- returns: The JiNode object found or nil if it doesn't exist.
	*/
	public func firstDescendantWithAttributeName(attributeName: String, attributeValue: String) -> JiNode? {
		return firstDescendantWithAttributeName(attributeName, attributeValue: attributeValue, node: self)
	}
	
	/**
	Helper method: Find the first descendant with the attribute name and value of the node provided.
	
	- parameter attributeName:  An attribute name.
	- parameter attributeValue: The attribute value for the attribute name.
	- parameter node:           The node from which to find.
	
	- returns: The JiNode object found or nil if it doesn't exist.
	*/
	private func firstDescendantWithAttributeName(attributeName: String, attributeValue: String, node: JiNode) -> JiNode? {
		if !node.hasChildren {
			return nil
		}
		
		for child in node {
			if child[attributeName] == attributeValue {
				return child
			}
			if let nodeFound = firstDescendantWithAttributeName(attributeName, attributeValue: attributeValue, node: child) {
				return nodeFound
			}
		}
		return nil
	}
	
	/**
	Find the descendants with the attribute name and value of this node.
	
	- parameter attributeName:  An attribute name.
	- parameter attributeValue: The attribute value for the attribute name.
	
	- returns: An array of JiNode.
	*/
	public func descendantsWithAttributeName(attributeName: String, attributeValue: String) -> [JiNode] {
		return descendantsWithAttributeName(attributeName, attributeValue: attributeValue, node: self)
	}
	
	/**
	Helper method: Find the descendants with the attribute name and value of the node provided.
	
	- parameter attributeName:  An attribute name.
	- parameter attributeValue: The attribute value for the attribute name.
	- parameter node:           The node from which to find.
	
	- returns: An array of JiNode.
	*/
	private func descendantsWithAttributeName(attributeName: String, attributeValue: String, node: JiNode) -> [JiNode] {
		if !node.hasChildren {
			return []
		}
		
		var results = [JiNode]()
		for child in node {
			if child[attributeName] == attributeValue {
				results.append(child)
			}
			results.appendContentsOf(descendantsWithAttributeName(attributeName, attributeValue: attributeValue, node: child))
		}
		return results
	}
}

// MARK: - Equatable
extension JiNode: Equatable { }
public func ==(lhs: JiNode, rhs: JiNode) -> Bool {
	if lhs.document == rhs.document && lhs.xmlNode != nil && rhs.xmlNode != nil {
		return xmlXPathCmpNodes(lhs.xmlNode, rhs.xmlNode) == 0
	}
	return false
}

// MARK: - SequenceType
extension JiNode: SequenceType {
	public func generate() -> JiNodeGenerator {
		return JiNodeGenerator(node: self)
	}
}

/// JiNodeGenerator
public class JiNodeGenerator: GeneratorType {
	private var node: JiNode?
	private var started = false
	public init(node: JiNode) {
		self.node = node
	}
	
	public func next() -> JiNode? {
		if !started {
			node = node?.firstChild
			started = true
		} else {
			node = node?.nextSibling
		}
		return node
	}
}

// MARK: - CustomStringConvertible
extension JiNode: CustomStringConvertible {
	public var description: String {
		return rawContent ?? "nil"
	}
}
