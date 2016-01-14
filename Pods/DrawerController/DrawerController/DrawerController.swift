// Copyright (c) 2014 evolved.io (http://evolved.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public extension UIViewController {
    var evo_drawerController: DrawerController? {
        var parentViewController = self.parentViewController
        
        while parentViewController != nil {
            if parentViewController!.isKindOfClass(DrawerController) {
                return parentViewController as? DrawerController
            }
            
            parentViewController = parentViewController!.parentViewController
        }
        
        return nil
    }
    
    var evo_visibleDrawerFrame: CGRect {
        if let drawerController = self.evo_drawerController {
            if drawerController.leftDrawerViewController != nil {
                if self == drawerController.leftDrawerViewController || self.navigationController == drawerController.leftDrawerViewController {
                    var rect = drawerController.view.bounds
                    rect.size.width = drawerController.maximumLeftDrawerWidth
                    return rect
                }
            }
            
            if drawerController.rightDrawerViewController != nil {
                if self == drawerController.rightDrawerViewController || self.navigationController == drawerController.rightDrawerViewController {
                    var rect = drawerController.view.bounds
                    rect.size.width = drawerController.maximumRightDrawerWidth
                    rect.origin.x = CGRectGetWidth(drawerController.view.bounds) - rect.size.width
                    return rect
                }
            }
        }
        
        return CGRectNull
    }
}

private func bounceKeyFrameAnimationForDistanceOnView(distance: CGFloat, view: UIView) -> CAKeyframeAnimation {
    let factors: [CGFloat] = [0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32, 0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0]
    
    let values = factors.map({ x in
        NSNumber(float: Float(x / 128 * distance + CGRectGetMidX(view.bounds)))
    })
    
    let animation = CAKeyframeAnimation(keyPath: "position.x")
    animation.repeatCount = 1
    animation.duration = 0.8
    animation.fillMode = kCAFillModeForwards
    animation.values = values
    animation.removedOnCompletion = true
    animation.autoreverses = false
    
    return animation
}

public enum DrawerSide: Int {
    case None
    case Left
    case Right
}

public struct OpenDrawerGestureMode: OptionSetType {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    public static let PanningNavigationBar = OpenDrawerGestureMode(rawValue: 0b0001)
    public static let PanningCenterView = OpenDrawerGestureMode(rawValue: 0b0010)
    public static let BezelPanningCenterView = OpenDrawerGestureMode(rawValue: 0b0100)
    public static let Custom = OpenDrawerGestureMode(rawValue: 0b1000)
    public static let All: OpenDrawerGestureMode = [PanningNavigationBar, PanningCenterView, BezelPanningCenterView, Custom]
}

public struct CloseDrawerGestureMode: OptionSetType {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    public static let PanningNavigationBar = CloseDrawerGestureMode(rawValue: 0b0000001)
    public static let PanningCenterView = CloseDrawerGestureMode(rawValue: 0b0000010)
    public static let BezelPanningCenterView = CloseDrawerGestureMode(rawValue: 0b0000100)
    public static let TapNavigationBar = CloseDrawerGestureMode(rawValue: 0b0001000)
    public static let TapCenterView = CloseDrawerGestureMode(rawValue: 0b0010000)
    public static let PanningDrawerView = CloseDrawerGestureMode(rawValue: 0b0100000)
    public static let Custom = CloseDrawerGestureMode(rawValue: 0b1000000)
    public static let All: CloseDrawerGestureMode = [PanningNavigationBar, PanningCenterView, BezelPanningCenterView, TapNavigationBar, TapCenterView, PanningDrawerView, Custom]
}

public enum DrawerOpenCenterInteractionMode: Int {
    case None
    case Full
    case NavigationBarOnly
}

private let DrawerDefaultWidth: CGFloat = 280.0
private let DrawerDefaultAnimationVelocity: CGFloat = 840.0

private let DrawerDefaultFullAnimationDelay: NSTimeInterval = 0.10

private let DrawerDefaultBounceDistance: CGFloat = 50.0

private let DrawerMinimumAnimationDuration: CGFloat = 0.15
private let DrawerDefaultDampingFactor: CGFloat = 1.0
private let DrawerDefaultShadowRadius: CGFloat = 10.0
private let DrawerDefaultShadowOpacity: Float = 0.8

private let DrawerPanVelocityXAnimationThreshold: CGFloat = 200.0

/** The amount of overshoot that is panned linearly. The remaining percentage nonlinearly asymptotes to the max percentage. */
private let DrawerOvershootLinearRangePercentage: CGFloat = 0.75

/** The percent of the possible overshoot width to use as the actual overshoot percentage. */
private let DrawerOvershootPercentage: CGFloat = 0.1

private let DrawerBezelRange: CGFloat = 20.0

private let DrawerLeftDrawerKey = "DrawerLeftDrawer"
private let DrawerRightDrawerKey = "DrawerRightDrawer"
private let DrawerCenterKey = "DrawerCenter"
private let DrawerOpenSideKey = "DrawerOpenSide"

public typealias DrawerGestureShouldRecognizeTouchBlock = (DrawerController, UIGestureRecognizer, UITouch) -> Bool
public typealias DrawerGestureCompletionBlock = (DrawerController, UIGestureRecognizer) -> Void
public typealias DrawerControllerDrawerVisualStateBlock = (DrawerController, DrawerSide, CGFloat) -> Void

private class DrawerCenterContainerView: UIView {
    private var openSide: DrawerSide = .None
    var centerInteractionMode: DrawerOpenCenterInteractionMode = .None
    
    private override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)
        
        if hitView != nil && self.openSide != .None {
            let navBar = self.navigationBarContainedWithinSubviewsOfView(self)
            
            if navBar != nil {
                let navBarFrame = navBar!.convertRect(navBar!.bounds, toView: self)
                if (self.centerInteractionMode == .NavigationBarOnly && CGRectContainsPoint(navBarFrame, point) == false) || (self.centerInteractionMode == .None) {
                    hitView = nil
                }
            }
        }
        
        return hitView
    }
    
    private func navigationBarContainedWithinSubviewsOfView(view: UIView) -> UINavigationBar? {
        var navBar: UINavigationBar?
        
        for subview in view.subviews as [UIView] {
            if view.isKindOfClass(UINavigationBar) {
                navBar = view as? UINavigationBar
                break
            } else {
                navBar = self.navigationBarContainedWithinSubviewsOfView(subview)
                if navBar != nil {
                    break
                }
            }
        }
        
        return navBar
    }
}

public class DrawerController: UIViewController, UIGestureRecognizerDelegate {
    private var _centerViewController: UIViewController?
    private var _leftDrawerViewController: UIViewController?
    private var _rightDrawerViewController: UIViewController?
    private var _maximumLeftDrawerWidth = DrawerDefaultWidth
    private var _maximumRightDrawerWidth = DrawerDefaultWidth
    
    /**
    The center view controller.
    
    This can only be set via the init methods, as well as the `setNewCenterViewController:...` methods. The size of this view controller will automatically be set to the size of the drawer container view controller, and it's position is modified from within this class. Do not modify the frame externally.
    */
    public var centerViewController: UIViewController? {
        get {
            return self._centerViewController
        }
        
        set {
            self.setCenterViewController(newValue, animated: false)
        }
    }
    
    /**
    The left drawer view controller.
    
    The size of this view controller is managed within this class, and is automatically set to the appropriate size based on the `maximumLeftDrawerWidth`. Do not modify the frame externally.
    */
    public var leftDrawerViewController: UIViewController? {
        get {
            return self._leftDrawerViewController
        }
        
        set {
            self.setDrawerViewController(newValue, forSide: .Left)
        }
    }
    
    /**
    The right drawer view controller.
    
    The size of this view controller is managed within this class, and is automatically set to the appropriate size based on the `maximumRightDrawerWidth`. Do not modify the frame externally.
    */
    public var rightDrawerViewController: UIViewController? {
        get {
            return self._rightDrawerViewController
        }
        
        set {
            self.setDrawerViewController(newValue, forSide: .Right)
        }
    }
    
    /**
    The maximum width of the `leftDrawerViewController`.
    
    By default, this is set to 280. If the `leftDrawerViewController` is nil, this property will return 0.0;
    */
    public var maximumLeftDrawerWidth: CGFloat {
        get {
            if self.leftDrawerViewController != nil {
                return self._maximumLeftDrawerWidth
            } else {
                return 0.0
            }
        }
        
        set {
            self.setMaximumLeftDrawerWidth(newValue, animated: false, completion: nil)
        }
    }
    
    /**
    The maximum width of the `rightDrawerViewController`.
    
    By default, this is set to 280. If the `rightDrawerViewController` is nil, this property will return 0.0;
    
    */
    public var maximumRightDrawerWidth: CGFloat {
        get {
            if self.rightDrawerViewController != nil {
                return self._maximumRightDrawerWidth
            } else {
                return 0.0
            }
        }
        
        set {
            self.setMaximumRightDrawerWidth(newValue, animated: false, completion: nil)
        }
    }
    
    /**
    The visible width of the `leftDrawerViewController`.
    
    Note this value can be greater than `maximumLeftDrawerWidth` during the full close animation when setting a new center view controller;
    */
    public var visibleLeftDrawerWidth: CGFloat {
        get {
            return max(0.0, CGRectGetMinX(self.centerContainerView.frame))
        }
    }
    
    /**
    The visible width of the `rightDrawerViewController`.
    
    Note this value can be greater than `maximumRightDrawerWidth` during the full close animation when setting a new center view controller;
    */
    public var visibleRightDrawerWidth: CGFloat {
        get {
            if CGRectGetMinX(self.centerContainerView.frame) < 0 {
                return CGRectGetWidth(self.childControllerContainerView.bounds) - CGRectGetMaxX(self.centerContainerView.frame)
            } else {
                return 0.0
            }
        }
    }
    
    /**
    A boolean that determines whether or not the panning gesture will "hard-stop" at the maximum width for a given drawer side.
    
    By default, this value is set to YES. Enabling `shouldStretchDrawer` will give the pan a gradual asymptotic stopping point much like `UIScrollView` behaves. Note that if this value is set to YES, the `drawerVisualStateBlock` can be passed a `percentVisible` greater than 1.0, so be sure to handle that case appropriately.
    */
    public var shouldStretchDrawer = true
    public var drawerDampingFactor = DrawerDefaultDampingFactor
    
    /**
    The flag determining if a shadow should be drawn off of `centerViewController` when a drawer is open.
    
    By default, this is set to YES.
    */
    public var showsShadows: Bool = true {
        didSet {
            self.updateShadowForCenterView()
        }
    }
    
    public var animationVelocity = DrawerDefaultAnimationVelocity
    private var animatingDrawer: Bool = false {
        didSet {
            self.view.userInteractionEnabled = !self.animatingDrawer
        }
    }
    
    private lazy var childControllerContainerView: UIView = {
        let childContainerViewFrame = self.view.bounds
        let childControllerContainerView = UIView(frame: childContainerViewFrame)
        childControllerContainerView.backgroundColor = UIColor.clearColor()
        childControllerContainerView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.view.addSubview(childControllerContainerView)
        
        return childControllerContainerView
        }()
    
    private lazy var centerContainerView: DrawerCenterContainerView = {
        let centerFrame = self.childControllerContainerView.bounds
        
        let centerContainerView = DrawerCenterContainerView(frame: centerFrame)
        centerContainerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        centerContainerView.backgroundColor = UIColor.clearColor()
        centerContainerView.openSide = self.openSide
        centerContainerView.centerInteractionMode = self.centerHiddenInteractionMode
        self.childControllerContainerView.addSubview(centerContainerView)
        
        return centerContainerView
        }()
    
    /**
    The current open side of the drawer.
    
    Note this value will change as soon as a pan gesture opens a drawer, or when a open/close animation is finished.
    */
    public private(set) var openSide: DrawerSide = .None {
        didSet {
            self.centerContainerView.openSide = self.openSide
            if self.openSide == .None {
                self.leftDrawerViewController?.view.hidden = true
                self.rightDrawerViewController?.view.hidden = true
            }
            
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private var startingPanRect: CGRect = CGRectNull
    
    /**
    Sets a callback to be called when a gesture has been completed.
    
    This block is called when a gesture action has been completed. You can query the `openSide` of the `drawerController` to determine what the new state of the drawer is.
    
    - parameter gestureCompletionBlock: A block object to be called that allows the implementer be notified when a gesture action has been completed.
    */
    public var gestureCompletionBlock: DrawerGestureCompletionBlock?
    
    /**
    Sets a callback to be called when a drawer visual state needs to be updated.
    
    This block is responsible for updating the drawer's view state, and the drawer controller will handle animating to that state from the current state. This block will be called when the drawer is opened or closed, as well when the user is panning the drawer. This block is not responsible for doing animations directly, but instead just updating the state of the properies (such as alpha, anchor point, transform, etc). Note that if `shouldStretchDrawer` is set to YES, it is possible for `percentVisible` to be greater than 1.0. If `shouldStretchDrawer` is set to NO, `percentVisible` will never be greater than 1.0.
    
    Note that when the drawer is finished opening or closing, the side drawer controller view will be reset with the following properies:
    
    - alpha: 1.0
    - transform: CATransform3DIdentity
    - anchorPoint: (0.5,0.5)
    
    - parameter drawerVisualStateBlock: A block object to be called that allows the implementer to update visual state properties on the drawer. `percentVisible` represents the amount of the drawer space that is current visible, with drawer space being defined as the edge of the screen to the maxmimum drawer width. Note that you do have access to the drawerController, which will allow you to update things like the anchor point of the side drawer layer.
    */
    public var drawerVisualStateBlock: DrawerControllerDrawerVisualStateBlock?
    
    /**
    Sets a callback to be called to determine if a UIGestureRecognizer should recieve the given UITouch.
    
    This block provides a way to allow a gesture to be recognized with custom logic. For example, you may have a certain part of your view that should accept a pan gesture recognizer to open the drawer, but not another a part. If you return YES, the gesture is recognized and the appropriate action is taken. This provides similar support to how Facebook allows you to pan on the background view of the main table view, but not the content itself. You can inspect the `openSide` property of the `drawerController` to determine the current state of the drawer, and apply the appropriate logic within your block.
    
    Note that either `openDrawerGestureModeMask` must contain `OpenDrawerGestureModeCustom`, or `closeDrawerGestureModeMask` must contain `CloseDrawerGestureModeCustom` for this block to be consulted.
    
    - parameter gestureShouldRecognizeTouchBlock: A block object to be called to determine if the given `touch` should be recognized by the given gesture.
    */
    public var gestureShouldRecognizeTouchBlock: DrawerGestureShouldRecognizeTouchBlock?
    
    /**
    How a user is allowed to open a drawer using gestures.
    
    By default, this is set to `OpenDrawerGestureModeNone`. Note these gestures may affect user interaction with the `centerViewController`, so be sure to use appropriately.
    */
    public var openDrawerGestureModeMask: OpenDrawerGestureMode = []
    
    /**
    How a user is allowed to close a drawer.
    
    By default, this is set to `CloseDrawerGestureModeNone`. Note these gestures may affect user interaction with the `centerViewController`, so be sure to use appropriately.
    */
    public var closeDrawerGestureModeMask: CloseDrawerGestureMode = []
    
    /**
    The value determining if the user can interact with the `centerViewController` when a side drawer is open.
    
    By default, it is `DrawerOpenCenterInteractionModeNavigationBarOnly`, meaning that the user can only interact with the buttons on the `UINavigationBar`, if the center view controller is a `UINavigationController`. Otherwise, the user cannot interact with any other center view controller elements.
    */
    public var centerHiddenInteractionMode: DrawerOpenCenterInteractionMode = .NavigationBarOnly {
        didSet {
            self.centerContainerView.centerInteractionMode = self.centerHiddenInteractionMode
        }
    }
    
    // MARK: - Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /**
    Creates and initializes an `DrawerController` object with the specified center view controller, left drawer view controller, and right drawer view controller.
    
    - parameter centerViewController: The center view controller. This argument must not be `nil`.
    - parameter leftDrawerViewController: The left drawer view controller.
    - parameter rightDrawerViewController: The right drawer controller.
    
    - returns: The newly-initialized drawer container view controller.
    */
    public init(centerViewController: UIViewController, leftDrawerViewController: UIViewController?, rightDrawerViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        
        self.centerViewController = centerViewController
        self.leftDrawerViewController = leftDrawerViewController
        self.rightDrawerViewController = rightDrawerViewController
    }
    
    /**
    Creates and initializes an `DrawerController` object with the specified center view controller, left drawer view controller.
    
    - parameter centerViewController: The center view controller. This argument must not be `nil`.
    - parameter leftDrawerViewController: The left drawer view controller.
    
    - returns: The newly-initialized drawer container view controller.
    */
    public convenience init(centerViewController: UIViewController, leftDrawerViewController: UIViewController?) {
        self.init(centerViewController: centerViewController, leftDrawerViewController: leftDrawerViewController, rightDrawerViewController: nil)
    }
    
    /**
    Creates and initializes an `DrawerController` object with the specified center view controller, right drawer view controller.
    
    - parameter centerViewController: The center view controller. This argument must not be `nil`.
    - parameter rightDrawerViewController: The right drawer controller.
    
    - returns: The newly-initialized drawer container view controller.
    */
    public convenience init(centerViewController: UIViewController, rightDrawerViewController: UIViewController?) {
        self.init(centerViewController: centerViewController, leftDrawerViewController: nil, rightDrawerViewController: rightDrawerViewController)
    }
    
    // MARK: - State Restoration
    
    public override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        if let leftDrawerViewController = self.leftDrawerViewController {
            coder.encodeObject(leftDrawerViewController, forKey: DrawerLeftDrawerKey)
        }
        
        if let rightDrawerViewController = self.rightDrawerViewController {
            coder.encodeObject(rightDrawerViewController, forKey: DrawerRightDrawerKey)
        }
        
        if let centerViewController = self.centerViewController {
            coder.encodeObject(centerViewController, forKey: DrawerCenterKey)
        }
        
        coder.encodeInteger(self.openSide.rawValue, forKey: DrawerOpenSideKey)
    }
    
    public override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        if let leftDrawerViewController: AnyObject = coder.decodeObjectForKey(DrawerLeftDrawerKey) {
            self.leftDrawerViewController = leftDrawerViewController as? UIViewController
        }
        
        if let rightDrawerViewController: AnyObject = coder.decodeObjectForKey(DrawerRightDrawerKey) {
            self.rightDrawerViewController = rightDrawerViewController as? UIViewController
        }
        
        if let centerViewController: AnyObject = coder.decodeObjectForKey(DrawerCenterKey) {
            self.centerViewController = centerViewController as? UIViewController
        }
        
        if let openSide = DrawerSide(rawValue: coder.decodeIntegerForKey(DrawerOpenSideKey)) {
            self.openSide = openSide
        }
    }
    
    // MARK: - UIViewController Containment
    
    override public func childViewControllerForStatusBarHidden() -> UIViewController? {
        return self.childViewControllerForSide(self.openSide)
    }
    
    override public func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.childViewControllerForSide(self.openSide)
    }
    
    // MARK: - Animation helpers
    
    private func finishAnimationForPanGestureWithXVelocity(xVelocity: CGFloat, completion: ((Bool) -> Void)?) {
        var currentOriginX = CGRectGetMinX(self.centerContainerView.frame)
        let animationVelocity = max(abs(xVelocity), DrawerPanVelocityXAnimationThreshold * 2)
        
        if self.openSide == .Left {
            let midPoint = self.maximumLeftDrawerWidth / 2.0
            
            if xVelocity > DrawerPanVelocityXAnimationThreshold {
                self.openDrawerSide(.Left, animated: true, velocity: animationVelocity, animationOptions: [], completion: completion)
            } else if xVelocity < -DrawerPanVelocityXAnimationThreshold {
                self.closeDrawerAnimated(true, velocity: animationVelocity, animationOptions: [], completion: completion)
            } else if currentOriginX < midPoint {
                self.closeDrawerAnimated(true, completion: completion)
            } else {
                self.openDrawerSide(.Left, animated: true, completion: completion)
            }
        } else if self.openSide == .Right {
            currentOriginX = CGRectGetMaxX(self.centerContainerView.frame)
            let midPoint = (CGRectGetWidth(self.childControllerContainerView.bounds) - self.maximumRightDrawerWidth) + (self.maximumRightDrawerWidth / 2.0)
            
            if xVelocity > DrawerPanVelocityXAnimationThreshold {
                self.closeDrawerAnimated(true, velocity: animationVelocity, animationOptions: [], completion: completion)
            } else if xVelocity < -DrawerPanVelocityXAnimationThreshold {
                self.openDrawerSide(.Right, animated: true, velocity: animationVelocity, animationOptions: [], completion: completion)
            } else if currentOriginX > midPoint {
                self.closeDrawerAnimated(true, completion: completion)
            } else {
                self.openDrawerSide(.Right, animated: true, completion: completion)
            }
        } else {
            completion?(false)
        }
    }
    
    private func updateDrawerVisualStateForDrawerSide(drawerSide: DrawerSide, percentVisible: CGFloat) {
        if let drawerVisualState = self.drawerVisualStateBlock {
            drawerVisualState(self, drawerSide, percentVisible)
        } else if self.shouldStretchDrawer {
            self.applyOvershootScaleTransformForDrawerSide(drawerSide, percentVisible: percentVisible)
        }
    }
    
    private func applyOvershootScaleTransformForDrawerSide(drawerSide: DrawerSide, percentVisible: CGFloat) {
        if percentVisible >= 1.0 {
            var transform = CATransform3DIdentity
            
            if let sideDrawerViewController = self.sideDrawerViewControllerForSide(drawerSide) {
                if drawerSide == .Left {
                    transform = CATransform3DMakeScale(percentVisible, 1.0, 1.0)
                    transform = CATransform3DTranslate(transform, self._maximumLeftDrawerWidth * (percentVisible - 1.0) / 2, 0, 0)
                } else if drawerSide == .Right {
                    transform = CATransform3DMakeScale(percentVisible, 1.0, 1.0)
                    transform = CATransform3DTranslate(transform, -self._maximumRightDrawerWidth * (percentVisible - 1.0) / 2, 0, 0)
                }
                
                sideDrawerViewController.view.layer.transform = transform
            }
        }
    }
    
    private func resetDrawerVisualStateForDrawerSide(drawerSide: DrawerSide) {
        if let sideDrawerViewController = self.sideDrawerViewControllerForSide(drawerSide) {
            sideDrawerViewController.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            sideDrawerViewController.view.layer.transform = CATransform3DIdentity
            sideDrawerViewController.view.alpha = 1.0
        }
    }
    
    private func roundedOriginXForDrawerConstraints(originX: CGFloat) -> CGFloat {
        if originX < -self.maximumRightDrawerWidth {
            if self.shouldStretchDrawer && self.rightDrawerViewController != nil {
                let maxOvershoot: CGFloat = (CGRectGetWidth(self.centerContainerView.frame) - self.maximumRightDrawerWidth) * DrawerOvershootPercentage
                return self.originXForDrawerOriginAndTargetOriginOffset(originX, targetOffset: -self.maximumRightDrawerWidth, maxOvershoot: maxOvershoot)
            } else {
                return -self.maximumRightDrawerWidth
            }
        } else if originX > self.maximumLeftDrawerWidth {
            if self.shouldStretchDrawer && self.leftDrawerViewController != nil {
                let maxOvershoot = (CGRectGetWidth(self.centerContainerView.frame) - self.maximumLeftDrawerWidth) * DrawerOvershootPercentage;
                return self.originXForDrawerOriginAndTargetOriginOffset(originX, targetOffset: self.maximumLeftDrawerWidth, maxOvershoot: maxOvershoot)
            } else {
                return self.maximumLeftDrawerWidth
            }
        }
        
        return originX
    }
    
    private func originXForDrawerOriginAndTargetOriginOffset(originX: CGFloat, targetOffset: CGFloat, maxOvershoot: CGFloat) -> CGFloat {
        let delta: CGFloat = abs(originX - targetOffset)
        let maxLinearPercentage = DrawerOvershootLinearRangePercentage
        let nonLinearRange = maxOvershoot * maxLinearPercentage
        let nonLinearScalingDelta = delta - nonLinearRange
        let overshoot = nonLinearRange + nonLinearScalingDelta * nonLinearRange / sqrt(pow(nonLinearScalingDelta, 2.0) + 15000)
        
        if delta < nonLinearRange {
            return originX
        } else if targetOffset < 0 {
            return targetOffset - round(overshoot)
        } else {
            return targetOffset + round(overshoot)
        }
    }
    
    // MARK: - Helpers
    
    private func setupGestureRecognizers() {
        let pan = UIPanGestureRecognizer(target: self, action: "panGestureCallback:")
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: "tapGestureCallback:")
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    private func childViewControllerForSide(drawerSide: DrawerSide) -> UIViewController? {
        var childViewController: UIViewController?
        
        switch drawerSide {
        case .Left:
            childViewController = self.leftDrawerViewController
        case .Right:
            childViewController = self.rightDrawerViewController
        case .None:
            childViewController = self.centerViewController
        }
        
        return childViewController
    }
    
    private func sideDrawerViewControllerForSide(drawerSide: DrawerSide) -> UIViewController? {
        var sideDrawerViewController: UIViewController?
        
        if drawerSide != .None {
            sideDrawerViewController = self.childViewControllerForSide(drawerSide)
        }
        
        return sideDrawerViewController
    }
    
    private func prepareToPresentDrawer(drawer: DrawerSide, animated: Bool) {
        var drawerToHide: DrawerSide = .None
        
        if drawer == .Left {
            drawerToHide = .Right
        } else if drawer == .Right {
            drawerToHide = .Left
        }
        
        if let sideDrawerViewControllerToHide = self.sideDrawerViewControllerForSide(drawerToHide) {
            self.childControllerContainerView.sendSubviewToBack(sideDrawerViewControllerToHide.view)
            sideDrawerViewControllerToHide.view.hidden = true
        }
        
        if let sideDrawerViewControllerToPresent = self.sideDrawerViewControllerForSide(drawer) {
            sideDrawerViewControllerToPresent.view.hidden = false
            self.resetDrawerVisualStateForDrawerSide(drawer)
            sideDrawerViewControllerToPresent.view.frame = sideDrawerViewControllerToPresent.evo_visibleDrawerFrame
            self.updateDrawerVisualStateForDrawerSide(drawer, percentVisible: 0.0)
            sideDrawerViewControllerToPresent.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    private func updateShadowForCenterView() {
        if self.showsShadows {
            self.centerContainerView.layer.masksToBounds = false
            self.centerContainerView.layer.shadowRadius = DrawerDefaultShadowRadius
            self.centerContainerView.layer.shadowOpacity = DrawerDefaultShadowOpacity
            
            /** In the event this gets called a lot, we won't update the shadowPath
            unless it needs to be updated (like during rotation) */
            if self.centerContainerView.layer.shadowPath == nil {
                self.centerContainerView.layer.shadowPath = UIBezierPath(rect: self.centerContainerView.bounds).CGPath
            } else {
                let currentPath = CGPathGetPathBoundingBox(self.centerContainerView.layer.shadowPath)
                
                if CGRectEqualToRect(currentPath, self.centerContainerView.bounds) == false {
                    self.centerContainerView.layer.shadowPath = UIBezierPath(rect: self.centerContainerView.bounds).CGPath
                }
            }
        } else if (self.centerContainerView.layer.shadowPath != nil) {
            self.centerContainerView.layer.shadowRadius = 0.0
            self.centerContainerView.layer.shadowOpacity = 0.0
            self.centerContainerView.layer.shadowPath = nil
            self.centerContainerView.layer.masksToBounds = true
        }
    }
    
    private func animationDurationForAnimationDistance(distance: CGFloat) -> NSTimeInterval {
        return NSTimeInterval(max(distance / self.animationVelocity, DrawerMinimumAnimationDuration))
    }
    
    // MARK: - Size Methods
    
    /**
    Sets the maximum width of the left drawer view controller.
    
    If the drawer is open, and `animated` is YES, it will animate the drawer frame as well as adjust the center view controller. If the drawer is not open, this change will take place immediately.
    
    - parameter width: The new width of left drawer view controller. This must be greater than zero.
    - parameter animated: Determines whether the drawer should be adjusted with an animation.
    - parameter completion: The block called when the animation is finished.
    
    */
    public func setMaximumLeftDrawerWidth(width: CGFloat, animated: Bool, completion: ((Bool) -> Void)?) {
        self.setMaximumDrawerWidth(width, forSide: .Left, animated: animated, completion: completion)
    }
    
    /**
    Sets the maximum width of the right drawer view controller.
    
    If the drawer is open, and `animated` is YES, it will animate the drawer frame as well as adjust the center view controller. If the drawer is not open, this change will take place immediately.
    
    - parameter width: The new width of right drawer view controller. This must be greater than zero.
    - parameter animated: Determines whether the drawer should be adjusted with an animation.
    - parameter completion: The block called when the animation is finished.
    
    */
    public func setMaximumRightDrawerWidth(width: CGFloat, animated: Bool, completion: ((Bool) -> Void)?) {
        self.setMaximumDrawerWidth(width, forSide: .Right, animated: animated, completion: completion)
    }
    
    private func setMaximumDrawerWidth(width: CGFloat, forSide drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return width > 0
            }(), "width must be greater than 0")
        
        assert({ () -> Bool in
            return drawerSide != .None
            }(), "drawerSide cannot be .None")
        
        if let sideDrawerViewController = self.sideDrawerViewControllerForSide(drawerSide) {
            var oldWidth: CGFloat = 0.0
            var drawerSideOriginCorrection: NSInteger = 1
            
            if drawerSide == .Left {
                oldWidth = self._maximumLeftDrawerWidth
                self._maximumLeftDrawerWidth = width
            } else if (drawerSide == .Right) {
                oldWidth = self._maximumRightDrawerWidth
                self._maximumRightDrawerWidth = width
                drawerSideOriginCorrection = -1
            }
            
            let distance: CGFloat = abs(width - oldWidth)
            let duration: NSTimeInterval = animated ? self.animationDurationForAnimationDistance(distance) : 0.0
            
            if self.openSide == drawerSide {
                var newCenterRect = self.centerContainerView.frame
                newCenterRect.origin.x = CGFloat(drawerSideOriginCorrection) * width
                
                UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: self.animationVelocity / distance, options: [], animations: { () -> Void in
                    self.centerContainerView.frame = newCenterRect
                    sideDrawerViewController.view.frame = sideDrawerViewController.evo_visibleDrawerFrame
                    }, completion: { (finished) -> Void in
                        completion?(finished)
                        return
                })
            } else {
                sideDrawerViewController.view.frame = sideDrawerViewController.evo_visibleDrawerFrame
                completion?(true)
            }
        }
    }
    
    // MARK: - Setters
    
    private func setRightDrawerViewController(rightDrawerViewController: UIViewController?) {
        self.setDrawerViewController(rightDrawerViewController, forSide: .Right)
    }
    
    private func setLeftDrawerViewController(leftDrawerViewController: UIViewController?) {
        self.setDrawerViewController(leftDrawerViewController, forSide: .Left)
    }
    
    private func setDrawerViewController(viewController: UIViewController?, forSide drawerSide: DrawerSide) {
        assert({ () -> Bool in
            return drawerSide != .None
            }(), "drawerSide cannot be .None")
        
        let currentSideViewController = self.sideDrawerViewControllerForSide(drawerSide)
        
        if currentSideViewController == viewController {
            return
        }
        
        if currentSideViewController != nil {
            currentSideViewController!.beginAppearanceTransition(false, animated: false)
            currentSideViewController!.view.removeFromSuperview()
            currentSideViewController!.endAppearanceTransition()
            currentSideViewController!.willMoveToParentViewController(nil)
            currentSideViewController!.removeFromParentViewController()
        }
        
        var autoResizingMask = UIViewAutoresizing()
        
        if drawerSide == .Left {
            self._leftDrawerViewController = viewController
            autoResizingMask = [.FlexibleRightMargin, .FlexibleHeight]
        } else if drawerSide == .Right {
            self._rightDrawerViewController = viewController
            autoResizingMask = [.FlexibleLeftMargin, .FlexibleHeight]
        }
        
        if viewController != nil {
            self.addChildViewController(viewController!)
            
            if (self.openSide == drawerSide) && (self.childControllerContainerView.subviews as NSArray).containsObject(self.centerContainerView) {
                self.childControllerContainerView.insertSubview(viewController!.view, belowSubview: self.centerContainerView)
                viewController!.beginAppearanceTransition(true, animated: false)
                viewController!.endAppearanceTransition()
            } else {
                self.childControllerContainerView.addSubview(viewController!.view)
                self.childControllerContainerView.sendSubviewToBack(viewController!.view)
                viewController!.view.hidden = true
            }
            
            viewController!.didMoveToParentViewController(self)
            viewController!.view.autoresizingMask = autoResizingMask
            viewController!.view.frame = viewController!.evo_visibleDrawerFrame
        }
    }
    
    // MARK: - Updating the Center View Controller
    
    private func setCenterViewController(centerViewController: UIViewController?, animated: Bool) {
        if self._centerViewController == centerViewController {
            return
        }
        
        if let oldCenterViewController = self._centerViewController {
            oldCenterViewController.willMoveToParentViewController(nil)
            
            if animated == false {
                oldCenterViewController.beginAppearanceTransition(false, animated: false)
            }
            
            oldCenterViewController.removeFromParentViewController()
            oldCenterViewController.view.removeFromSuperview()
            
            if animated == false {
                oldCenterViewController.endAppearanceTransition()
            }
        }
        
        self._centerViewController = centerViewController
        
        if self._centerViewController != nil {
            self.addChildViewController(self._centerViewController!)
            self._centerViewController!.view.frame = self.childControllerContainerView.bounds
            self.centerContainerView.addSubview(self._centerViewController!.view)
            self.childControllerContainerView.bringSubviewToFront(self.centerContainerView)
            self._centerViewController!.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.updateShadowForCenterView()
            
            if animated == false {
                // If drawer is offscreen, then viewWillAppear: will take care of this
                if self.view.window != nil {
                    self._centerViewController!.beginAppearanceTransition(true, animated: false)
                    self._centerViewController!.endAppearanceTransition()
                }
                
                self._centerViewController!.didMoveToParentViewController(self)
            }
        }
    }
    
    /**
    Sets the new `centerViewController`.
    
    This sets the view controller and will automatically adjust the frame based on the current state of the drawer controller. If `closeAnimated` is YES, it will immediately change the center view controller, and close the drawer from its current position.
    
    - parameter centerViewController: The new `centerViewController`.
    - parameter closeAnimated: Determines whether the drawer should be closed with an animation.
    - parameter completion: The block called when the animation is finsihed.
    
    */
    public func setCenterViewController(newCenterViewController: UIViewController, var withCloseAnimation animated: Bool, completion: ((Bool) -> Void)?) {
        if self.openSide == .None {
            // If a side drawer isn't open, there is nothing to animate
            animated = false
        }
        
        let forwardAppearanceMethodsToCenterViewController = (self.centerViewController! == newCenterViewController) == false
        self.setCenterViewController(newCenterViewController, animated: animated)
        
        if animated {
            self.updateDrawerVisualStateForDrawerSide(self.openSide, percentVisible: 1.0)
            
            if forwardAppearanceMethodsToCenterViewController {
                self.centerViewController!.beginAppearanceTransition(true, animated: animated)
            }
            
            self.closeDrawerAnimated(animated, completion: { (finished) in
                if forwardAppearanceMethodsToCenterViewController {
                    self.centerViewController!.endAppearanceTransition()
                    self.centerViewController!.didMoveToParentViewController(self)
                }
                
                completion?(finished)
            })
        } else {
            completion?(true)
        }
    }
    
    /**
    Sets the new `centerViewController`.
    
    This sets the view controller and will automatically adjust the frame based on the current state of the drawer controller. If `closeFullAnimated` is YES, the current center view controller will animate off the screen, the new center view controller will then be set, followed by the drawer closing across the full width of the screen.
    
    - parameter newCenterViewController: The new `centerViewController`.
    - parameter fullCloseAnimated: Determines whether the drawer should be closed with an animation.
    - parameter completion: The block called when the animation is finsihed.
    
    */
    public func setCenterViewController(newCenterViewController: UIViewController, withFullCloseAnimation animated: Bool, completion: ((Bool) -> Void)?) {
        if self.openSide != .None && animated {
            let forwardAppearanceMethodsToCenterViewController = (self.centerViewController! == newCenterViewController) == false
            let sideDrawerViewController = self.sideDrawerViewControllerForSide(self.openSide)
            
            var targetClosePoint: CGFloat = 0.0
            
            if self.openSide == .Right {
                targetClosePoint = -CGRectGetWidth(self.childControllerContainerView.bounds)
            } else if self.openSide == .Left {
                targetClosePoint = CGRectGetWidth(self.childControllerContainerView.bounds)
            }
            
            let distance: CGFloat = abs(self.centerContainerView.frame.origin.x - targetClosePoint)
            let firstDuration = self.animationDurationForAnimationDistance(distance)
            
            var newCenterRect = self.centerContainerView.frame
            
            self.animatingDrawer = animated
            
            let oldCenterViewController = self.centerViewController
            
            if forwardAppearanceMethodsToCenterViewController {
                oldCenterViewController?.beginAppearanceTransition(false, animated: animated)
            }
            
            newCenterRect.origin.x = targetClosePoint
            
            UIView.animateWithDuration(firstDuration, delay: 0.0, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: distance / self.animationVelocity, options: [], animations: { () -> Void in
                self.centerContainerView.frame = newCenterRect
                sideDrawerViewController?.view.frame = self.childControllerContainerView.bounds
                }, completion: { (finished) -> Void in
                    let oldCenterRect = self.centerContainerView.frame
                    self.setCenterViewController(newCenterViewController, animated: animated)
                    self.centerContainerView.frame = oldCenterRect
                    self.updateDrawerVisualStateForDrawerSide(self.openSide, percentVisible: 1.0)
                    
                    if forwardAppearanceMethodsToCenterViewController {
                        oldCenterViewController?.endAppearanceTransition()
                        self.centerViewController?.beginAppearanceTransition(true, animated: animated)
                    }
                    
                    sideDrawerViewController?.beginAppearanceTransition(false, animated: animated)
                    
                    UIView.animateWithDuration(self.animationDurationForAnimationDistance(CGRectGetWidth(self.childControllerContainerView.bounds)), delay: DrawerDefaultFullAnimationDelay, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: CGRectGetWidth(self.childControllerContainerView.bounds) / self.animationVelocity, options: [], animations: { () -> Void in
                        self.centerContainerView.frame = self.childControllerContainerView.bounds
                        self.updateDrawerVisualStateForDrawerSide(self.openSide, percentVisible: 0.0)
                        }, completion: { (finished) -> Void in
                            if forwardAppearanceMethodsToCenterViewController {
                                self.centerViewController?.endAppearanceTransition()
                                self.centerViewController?.didMoveToParentViewController(self)
                            }
                            
                            sideDrawerViewController?.endAppearanceTransition()
                            self.resetDrawerVisualStateForDrawerSide(self.openSide)
                            
                            if sideDrawerViewController != nil {
                                sideDrawerViewController!.view.frame = sideDrawerViewController!.evo_visibleDrawerFrame
                            }
                            
                            self.openSide = .None
                            self.animatingDrawer = false
                            
                            completion?(finished)
                    })
            })
        } else {
            self.setCenterViewController(newCenterViewController, animated: animated)
            
            if self.openSide != .None {
                self.closeDrawerAnimated(animated, completion: completion)
            } else if completion != nil {
                completion!(true)
            }
        }
    }
    
    // MARK: - Bounce Methods
    
    /**
    Bounce preview for the specified `drawerSide` a distance of 40 points.
    
    - parameter drawerSide: The drawer to preview. This value cannot be `DrawerSideNone`.
    - parameter completion: The block called when the animation is finsihed.
    
    */
    public func bouncePreviewForDrawerSide(drawerSide: DrawerSide, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .None
            }(), "drawerSide cannot be .None")
        
        self.bouncePreviewForDrawerSide(drawerSide, distance: DrawerDefaultBounceDistance, completion: nil)
    }
    
    /**
    Bounce preview for the specified `drawerSide`.
    
    - parameter drawerSide: The drawer side to preview. This value cannot be `DrawerSideNone`.
    - parameter distance: The distance to bounce.
    - parameter completion: The block called when the animation is finsihed.
    
    */
    public func bouncePreviewForDrawerSide(drawerSide: DrawerSide, distance: CGFloat, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .None
            }(), "drawerSide cannot be .None")
        
        let sideDrawerViewController = self.sideDrawerViewControllerForSide(drawerSide)
        
        if sideDrawerViewController == nil || self.openSide != .None {
            completion?(false)
            return
        } else {
            self.prepareToPresentDrawer(drawerSide, animated: true)
            
            self.updateDrawerVisualStateForDrawerSide(drawerSide, percentVisible: 1.0)
            
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                sideDrawerViewController!.endAppearanceTransition()
                sideDrawerViewController!.beginAppearanceTransition(false, animated: false)
                sideDrawerViewController!.endAppearanceTransition()
                
                completion?(true)
            }
            
            let modifier: CGFloat = (drawerSide == .Left) ? 1.0 : -1.0
            let animation = bounceKeyFrameAnimationForDistanceOnView(distance * modifier, view: self.centerContainerView)
            self.centerContainerView.layer.addAnimation(animation, forKey: "bouncing")
            
            CATransaction.commit()
        }
    }
    
    // MARK: - Gesture Handlers
    
    func tapGestureCallback(tapGesture: UITapGestureRecognizer) {
        if self.openSide != .None && self.animatingDrawer == false {
            self.closeDrawerAnimated(true, completion: { (finished) in
                if self.gestureCompletionBlock != nil {
                    self.gestureCompletionBlock!(self, tapGesture)
                }
            })
        }
    }
    
    func panGestureCallback(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .Began:
            if self.animatingDrawer {
                panGesture.enabled = false
            } else {
                self.startingPanRect = self.centerContainerView.frame
            }
        case .Changed:
            self.view.userInteractionEnabled = false
            var newFrame = self.startingPanRect
            let translatedPoint = panGesture.translationInView(self.centerContainerView)
            newFrame.origin.x = self.roundedOriginXForDrawerConstraints(CGRectGetMinX(self.startingPanRect) + translatedPoint.x)
            newFrame = CGRectIntegral(newFrame)
            let xOffset = newFrame.origin.x
            
            var visibleSide: DrawerSide = .None
            var percentVisible: CGFloat = 0.0
            
            if xOffset > 0 {
                visibleSide = .Left
                percentVisible = xOffset / self.maximumLeftDrawerWidth
            } else if xOffset < 0 {
                visibleSide = .Right
                percentVisible = abs(xOffset) / self.maximumRightDrawerWidth
            }
            
            if let visibleSideDrawerViewController = self.sideDrawerViewControllerForSide(visibleSide) {
                if self.openSide != visibleSide {
                    // Handle disappearing the visible drawer
                    if let sideDrawerViewController = self.sideDrawerViewControllerForSide(self.openSide) {
                        sideDrawerViewController.beginAppearanceTransition(false, animated: false)
                        sideDrawerViewController.endAppearanceTransition()
                    }
                    
                    // Drawer is about to become visible
                    self.prepareToPresentDrawer(visibleSide, animated: false)
                    visibleSideDrawerViewController.endAppearanceTransition()
                    self.openSide = visibleSide
                } else if visibleSide == .None {
                    self.openSide = .None
                }
                
                self.updateDrawerVisualStateForDrawerSide(visibleSide, percentVisible: percentVisible)
                self.centerContainerView.center = CGPoint(x: CGRectGetMidX(newFrame), y: CGRectGetMidY(newFrame))
            }
        case .Ended, .Cancelled:
            self.startingPanRect = CGRectNull
            let velocity = panGesture.velocityInView(self.childControllerContainerView)
            self.finishAnimationForPanGestureWithXVelocity(velocity.x, completion:{ (finished) in
                if self.gestureCompletionBlock != nil {
                    self.gestureCompletionBlock!(self, panGesture)
                }
            })
            
            self.view.userInteractionEnabled = true
        default:
            break
        }
    }
    
    // MARK: - Open / Close Methods
    
    // DrawerSide enum is not exported to Objective-C, so use these two methods instead
    public func toggleLeftDrawerSideAnimated(animated: Bool, completion: ((Bool) -> Void)?) {
        self.toggleDrawerSide(.Left, animated: animated, completion: completion)
    }
    
    public func toggleRightDrawerSideAnimated(animated: Bool, completion: ((Bool) -> Void)?) {
        self.toggleDrawerSide(.Right, animated: animated, completion: completion)
    }
    
    /**
    Toggles the drawer open/closed based on the `drawer` passed in.
    
    Note that if you attempt to toggle a drawer closed while the other is open, nothing will happen. For example, if you pass in DrawerSideLeft, but the right drawer is open, nothing will happen. In addition, the completion block will be called with the finished flag set to NO.
    
    - parameter drawerSide: The `DrawerSide` to toggle. This value cannot be `DrawerSideNone`.
    - parameter animated: Determines whether the `drawer` should be toggle animated.
    - parameter completion: The block that is called when the toggle is complete, or if no toggle took place at all.
    
    */
    public func toggleDrawerSide(drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .None
            }(), "drawerSide cannot be .None")
        
        if self.openSide == DrawerSide.None {
            self.openDrawerSide(drawerSide, animated: animated, completion: completion)
        } else {
            if (drawerSide == DrawerSide.Left && self.openSide == DrawerSide.Left) || (drawerSide == DrawerSide.Right && self.openSide == DrawerSide.Right) {
                self.closeDrawerAnimated(animated, completion: completion)
            } else if completion != nil {
                completion!(false)
            }
        }
    }
    
    /**
    Opens the `drawer` passed in.
    
    - parameter drawerSide: The `DrawerSide` to open. This value cannot be `DrawerSideNone`.
    - parameter animated: Determines whether the `drawer` should be open animated.
    - parameter completion: The block that is called when the toggle is open.
    
    */
    public func openDrawerSide(drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .None
            }(), "drawerSide cannot be .None")
        
        self.openDrawerSide(drawerSide, animated: animated, velocity: self.animationVelocity, animationOptions: [], completion: completion)
    }
    
    private func openDrawerSide(drawerSide: DrawerSide, animated: Bool, velocity: CGFloat, animationOptions options: UIViewAnimationOptions, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .None
            }(), "drawerSide cannot be .None")
        
        if self.animatingDrawer {
            completion?(false)
        } else {
            self.animatingDrawer = animated
            let sideDrawerViewController = self.sideDrawerViewControllerForSide(drawerSide)
            
            if self.openSide != drawerSide {
                self.prepareToPresentDrawer(drawerSide, animated: animated)
            }
            
            if sideDrawerViewController != nil {
                var newFrame: CGRect
                let oldFrame = self.centerContainerView.frame
                
                if drawerSide == .Left {
                    newFrame = self.centerContainerView.frame
                    newFrame.origin.x = self._maximumLeftDrawerWidth
                } else {
                    newFrame = self.centerContainerView.frame
                    newFrame.origin.x = 0 - self._maximumRightDrawerWidth
                }
                
                let distance = abs(CGRectGetMinX(oldFrame) - newFrame.origin.x)
                let duration: NSTimeInterval = animated ? NSTimeInterval(max(distance / abs(velocity), DrawerMinimumAnimationDuration)) : 0.0
                
                UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: velocity / distance, options: options, animations: { () -> Void in
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.centerContainerView.frame = newFrame
                    self.updateDrawerVisualStateForDrawerSide(drawerSide, percentVisible: 1.0)
                    }, completion: { (finished) -> Void in
                        if drawerSide != self.openSide {
                            sideDrawerViewController!.endAppearanceTransition()
                        }
                        
                        self.openSide = drawerSide
                        
                        self.resetDrawerVisualStateForDrawerSide(drawerSide)
                        self.animatingDrawer = false
                        
                        completion?(finished)
                })
            }
        }
    }
    
    /**
    Closes the open drawer.
    
    - parameter animated: Determines whether the drawer side should be closed animated
    - parameter completion: The block that is called when the close is complete
    
    */
    public func closeDrawerAnimated(animated: Bool, completion: ((Bool) -> Void)?) {
        self.closeDrawerAnimated(animated, velocity: self.animationVelocity, animationOptions: [], completion: completion)
    }
    
    private func closeDrawerAnimated(animated: Bool, velocity: CGFloat, animationOptions options: UIViewAnimationOptions, completion: ((Bool) -> Void)?) {
        if self.animatingDrawer {
            completion?(false)
        } else {
            self.animatingDrawer = animated
            let newFrame = self.childControllerContainerView.bounds
            
            let distance = abs(CGRectGetMinX(self.centerContainerView.frame))
            let duration: NSTimeInterval = animated ? NSTimeInterval(max(distance / abs(velocity), DrawerMinimumAnimationDuration)) : 0.0
            
            let leftDrawerVisible = CGRectGetMinX(self.centerContainerView.frame) > 0
            let rightDrawerVisible = CGRectGetMinX(self.centerContainerView.frame) < 0
            
            var visibleSide: DrawerSide = .None
            var percentVisible: CGFloat = 0.0
            
            if leftDrawerVisible {
                let visibleDrawerPoint = CGRectGetMinX(self.centerContainerView.frame)
                percentVisible = max(0.0, visibleDrawerPoint / self._maximumLeftDrawerWidth)
                visibleSide = .Left
            } else if rightDrawerVisible {
                let visibleDrawerPoints = CGRectGetWidth(self.centerContainerView.frame) - CGRectGetMaxX(self.centerContainerView.frame)
                percentVisible = max(0.0, visibleDrawerPoints / self._maximumRightDrawerWidth)
                visibleSide = .Right
            }
            
            let sideDrawerViewController = self.sideDrawerViewControllerForSide(visibleSide)
            
            self.updateDrawerVisualStateForDrawerSide(visibleSide, percentVisible: percentVisible)
            sideDrawerViewController?.beginAppearanceTransition(false, animated: animated)
            
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: self.drawerDampingFactor, initialSpringVelocity: velocity / distance, options: options, animations: { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
                self.centerContainerView.frame = newFrame
                self.updateDrawerVisualStateForDrawerSide(visibleSide, percentVisible: 0.0)
                }, completion: { (finished) -> Void in
                    sideDrawerViewController?.endAppearanceTransition()
                    self.openSide = .None
                    self.resetDrawerVisualStateForDrawerSide(visibleSide)
                    self.animatingDrawer = false
                    completion?(finished)
            })
        }
    }
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.setupGestureRecognizers()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.centerViewController?.beginAppearanceTransition(true, animated: animated)
        
        if self.openSide == .Left {
            self.leftDrawerViewController?.beginAppearanceTransition(true, animated: animated)
        } else if self.openSide == .Right {
            self.rightDrawerViewController?.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateShadowForCenterView()
        self.centerViewController?.endAppearanceTransition()
        
        if self.openSide == .Left {
            self.leftDrawerViewController?.endAppearanceTransition()
        } else if self.openSide == .Right {
            self.rightDrawerViewController?.endAppearanceTransition()
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.centerViewController?.beginAppearanceTransition(false, animated: animated)
        
        if self.openSide == .Left {
            self.leftDrawerViewController?.beginAppearanceTransition(false, animated: animated)
        } else if self.openSide == .Right {
            self.rightDrawerViewController?.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.centerViewController?.endAppearanceTransition()
        
        if self.openSide == .Left {
            self.leftDrawerViewController?.endAppearanceTransition()
        } else if self.openSide == .Right {
            self.rightDrawerViewController?.endAppearanceTransition()
        }
    }
    
    public override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return false
    }
    
    // MARK: - Rotation
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        //If a rotation begins, we are going to cancel the current gesture and reset transform and anchor points so everything works correctly
        var gestureInProgress = false
        
        for gesture in self.view.gestureRecognizers! as [UIGestureRecognizer] {
            if gesture.state == .Changed {
                gesture.enabled = false
                gesture.enabled = true
                gestureInProgress = true
            }
            
            if gestureInProgress {
                self.resetDrawerVisualStateForDrawerSide(self.openSide)
            }
        }
        
        coordinator.animateAlongsideTransition({ (context) -> Void in
            //We need to support the shadow path rotation animation
            //Inspired from here: http://blog.radi.ws/post/8348898129/calayers-shadowpath-and-uiview-autoresizing
            if self.showsShadows {
                let oldShadowPath = self.centerContainerView.layer.shadowPath
                
                self.updateShadowForCenterView()
                
                if oldShadowPath != nil {
                    let transition = CABasicAnimation(keyPath: "shadowPath")
                    transition.fromValue = oldShadowPath
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.duration = context.transitionDuration()
                    self.centerContainerView.layer.addAnimation(transition, forKey: "transition")
                }
            }
        }, completion:nil)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if self.openSide == .None {
            let possibleOpenGestureModes = self.possibleOpenGestureModesForGestureRecognizer(gestureRecognizer, withTouch: touch)
            
            return !self.openDrawerGestureModeMask.intersect(possibleOpenGestureModes).isEmpty
        } else {
            let possibleCloseGestureModes = self.possibleCloseGestureModesForGestureRecognizer(gestureRecognizer, withTouch: touch)
            
            return !self.closeDrawerGestureModeMask.intersect(possibleCloseGestureModes).isEmpty
        }
    }
    
    // MARK: - Gesture Recognizer Delegate Helpers
    
    func possibleCloseGestureModesForGestureRecognizer(gestureRecognizer: UIGestureRecognizer, withTouch touch: UITouch) -> CloseDrawerGestureMode {
        let point = touch.locationInView(self.childControllerContainerView)
        var possibleCloseGestureModes: CloseDrawerGestureMode = []
        
        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) {
            if self.isPointContainedWithinNavigationRect(point) {
                possibleCloseGestureModes.insert(.TapNavigationBar)
            }
            
            if self.isPointContainedWithinCenterViewContentRect(point) {
                possibleCloseGestureModes.insert(.TapCenterView)
            }
        } else if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer) {
            if self.isPointContainedWithinNavigationRect(point) {
                possibleCloseGestureModes.insert(.PanningNavigationBar)
            }
            
            if self.isPointContainedWithinCenterViewContentRect(point) {
                possibleCloseGestureModes.insert(.PanningCenterView)
            }
            
            if self.isPointContainedWithinRightBezelRect(point) && self.openSide == .Left {
                possibleCloseGestureModes.insert(.BezelPanningCenterView)
            }
            
            if self.isPointContainedWithinLeftBezelRect(point) && self.openSide == .Right {
                possibleCloseGestureModes.insert(.BezelPanningCenterView)
            }
            
            if self.isPointContainedWithinCenterViewContentRect(point) == false && self.isPointContainedWithinNavigationRect(point) == false {
                possibleCloseGestureModes.insert(.PanningDrawerView)
            }
        }
        
        if self.closeDrawerGestureModeMask.contains(.Custom) && self.gestureShouldRecognizeTouchBlock != nil {
            if self.gestureShouldRecognizeTouchBlock!(self, gestureRecognizer, touch) {
                possibleCloseGestureModes.insert(.Custom)
            }
        }
        
        return possibleCloseGestureModes
    }
    
    func possibleOpenGestureModesForGestureRecognizer(gestureRecognizer: UIGestureRecognizer, withTouch touch: UITouch) -> OpenDrawerGestureMode {
        let point = touch.locationInView(self.childControllerContainerView)
        var possibleOpenGestureModes: OpenDrawerGestureMode = []
        
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer) {
            if self.isPointContainedWithinNavigationRect(point) {
                possibleOpenGestureModes.insert(.PanningNavigationBar)
            }
            
            if self.isPointContainedWithinCenterViewContentRect(point) {
                possibleOpenGestureModes.insert(.PanningCenterView)
            }
            
            if self.isPointContainedWithinLeftBezelRect(point) && self.leftDrawerViewController != nil {
                possibleOpenGestureModes.insert(.BezelPanningCenterView)
            }
            
            if self.isPointContainedWithinRightBezelRect(point) && self.rightDrawerViewController != nil {
                possibleOpenGestureModes.insert(.BezelPanningCenterView)
            }
        }
        
        if self.openDrawerGestureModeMask.contains(.Custom) && self.gestureShouldRecognizeTouchBlock != nil {
            if self.gestureShouldRecognizeTouchBlock!(self, gestureRecognizer, touch) {
                possibleOpenGestureModes.insert(.Custom)
            }
        }
        
        return possibleOpenGestureModes
    }
    
    func isPointContainedWithinNavigationRect(point: CGPoint) -> Bool {
        var navigationBarRect = CGRectNull
        
        if let centerViewController = self.centerViewController {
            if centerViewController.isKindOfClass(UINavigationController) {
                let navBar = (self.centerViewController as! UINavigationController).navigationBar
                navigationBarRect = navBar.convertRect(navBar.bounds, toView: self.childControllerContainerView)
                navigationBarRect = CGRectIntersection(navigationBarRect, self.childControllerContainerView.bounds)
            }
        }
        
        return CGRectContainsPoint(navigationBarRect, point)
    }
    
    func isPointContainedWithinCenterViewContentRect(point: CGPoint) -> Bool {
        var centerViewContentRect = self.centerContainerView.frame
        centerViewContentRect = CGRectIntersection(centerViewContentRect, self.childControllerContainerView.bounds)
        
        return CGRectContainsPoint(centerViewContentRect, point) && self.isPointContainedWithinNavigationRect(point) == false
    }
    
    func isPointContainedWithinLeftBezelRect(point: CGPoint) -> Bool {
        var leftBezelRect = CGRectNull
        var tempRect = CGRectNull
        
        CGRectDivide(self.childControllerContainerView.bounds, &leftBezelRect, &tempRect, DrawerBezelRange, .MinXEdge)
        
        return CGRectContainsPoint(leftBezelRect, point) && self.isPointContainedWithinCenterViewContentRect(point)
    }
    
    func isPointContainedWithinRightBezelRect(point: CGPoint) -> Bool {
        var rightBezelRect = CGRectNull
        var tempRect = CGRectNull
        
        CGRectDivide(self.childControllerContainerView.bounds, &rightBezelRect, &tempRect, DrawerBezelRange, .MaxXEdge)
        
        return CGRectContainsPoint(rightBezelRect, point) && self.isPointContainedWithinCenterViewContentRect(point)
    }
}
