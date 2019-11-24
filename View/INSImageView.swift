//
//  INSImageView.swift
//
//  Created by Patrick on 9/12/2015.
//  Copyright © 2015 instil. All rights reserved.
//

import UIKit

open class INSImageView: UIImageView {
    
    // MARK: - Public Properties
    
    // Use this to access the intended 'image' and `highlightedImage` properties.
    // Due to the way INSImageView is implemented, the 'image' and `highlightedImage` properties will always return nil.
    open var originalImage: UIImage?            { return imageView.image }
    open var originalHighlightedImage: UIImage? { return imageView.highlightedImage }
    
    // MARK: - Private Properties
    
    fileprivate let imageView = UIImageView()
    
    // MARK: - Initializers
    
    public init() {
        super.init(image: nil, highlightedImage: nil)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image, highlightedImage: nil)
        setup()
    }
    
    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        addSubview(imageView)
    }
    
    // MARK: - When to Relayout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutImageView()
    }
    
    open override var contentMode: UIView.ContentMode {
        didSet { layoutImageView() }
    }
    
    // MARK: - Manipulating Private imageView
    
    fileprivate func layoutImageView() {
        
        guard let image = imageView.image else { return }
        
        // MARK: - Layout Helpers
        func imageToBoundsWidthRatio(_ image: UIImage) -> CGFloat  { return image.size.width / bounds.size.width }
        func imageToBoundsHeightRatio(_ image: UIImage) -> CGFloat { return image.size.height / bounds.size.height }
        func centerImageViewToPoint(_ point: CGPoint)              { imageView.center = point }
        func imageViewBoundsToImageSize()                        { imageViewBoundsToSize(image.size) }
        func imageViewBoundsToSize(_ size: CGSize)                 { imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height) }
        func centerImageView()                                   { imageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2) }
        
        // MARK: - Layouts
        func layoutAspectFit() {
            let widthRatio = imageToBoundsWidthRatio(image)
            let heightRatio = imageToBoundsHeightRatio(image)
            imageViewBoundsToSize(CGSize(width: image.size.width / max(widthRatio, heightRatio), height: image.size.height / max(widthRatio, heightRatio)))
            centerImageView()
        }
        
        func layoutAspectFill() {
            let widthRatio = imageToBoundsWidthRatio(image)
            let heightRatio = imageToBoundsHeightRatio(image)
            imageViewBoundsToSize(CGSize(width: image.size.width /  min(widthRatio, heightRatio), height: image.size.height / min(widthRatio, heightRatio)))
            centerImageView()
        }
        
        func layoutFill() {
            imageViewBoundsToSize(CGSize(width: bounds.size.width, height: bounds.size.height))
        }
        
        func layoutCenter() {
            imageViewBoundsToImageSize()
            centerImageView()
        }
        
        func layoutTop() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(CGPoint(x: bounds.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutBottom() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(CGPoint(x: bounds.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        func layoutLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(CGPoint(x: image.size.width / 2, y: bounds.size.height / 2))
        }
        
        func layoutRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(CGPoint(x: bounds.size.width - image.size.width / 2, y: bounds.size.height / 2))
        }
        
        func layoutTopLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(CGPoint(x: image.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutTopRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(CGPoint(x: bounds.size.width - image.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutBottomLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(CGPoint(x: image.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        func layoutBottomRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(CGPoint(x: bounds.size.width - image.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        switch contentMode {
        case .scaleAspectFit:  layoutAspectFit()
        case .scaleAspectFill: layoutAspectFill()
        case .scaleToFill:     layoutFill()
        case .redraw:          break;
        case .center:          layoutCenter()
        case .top:             layoutTop()
        case .bottom:          layoutBottom()
        case .left:            layoutLeft()
        case .right:           layoutRight()
        case .topLeft:         layoutTopLeft()
        case .topRight:        layoutTopRight()
        case .bottomLeft:      layoutBottomLeft()
        case .bottomRight:     layoutBottomRight()
        }
    }
    
    // MARK: - Forwarding (Swift doesn't support forwardInvocation :c)
    
    open override var image: UIImage? {
        get { return nil }
        set { imageView.image = newValue }
    }
    
    open override var highlightedImage: UIImage? {
        get { return nil }
        set { imageView.highlightedImage = newValue }
    }
    
    open override var animationImages: [UIImage]? {
        get { return imageView.animationImages }
        set { imageView.animationImages = newValue }
    }
    
    open override var highlightedAnimationImages: [UIImage]? {
        get { return imageView.highlightedAnimationImages }
        set { imageView.highlightedAnimationImages = newValue }
    }
    
    open override var animationDuration: TimeInterval {
        get { return imageView.animationDuration }
        set { imageView.animationDuration = newValue }
    }
    
    open override var animationRepeatCount: Int {
        get { return imageView.animationRepeatCount }
        set { imageView.animationRepeatCount = newValue }
    }
    
    open override var isHighlighted: Bool {
        get { return imageView.isHighlighted }
        set { imageView.isHighlighted = newValue }
    }
    
    open override var tintColor: UIColor! {
        get { return imageView.tintColor }
        set { imageView.tintColor = newValue }
    }
    
    open override func startAnimating() {
        imageView.startAnimating()
    }
    
    open override func stopAnimating() {
        imageView.stopAnimating()
    }
    
    open override var isAnimating : Bool {
        return imageView.isAnimating
    }
}
