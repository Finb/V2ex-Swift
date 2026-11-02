//
//  SceneDelegate.swift
//  V2ex-Swift
//

import UIKit
import DrawerController
import SVProgressHUD

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = V2Window(windowScene: windowScene)
        self.window = window
        V2Client.sharedInstance.window = window
        window.makeKeyAndVisible()

        let centerNav = V2EXNavigationController(rootViewController: HomeViewController())
        let leftViewController = LeftViewController()
        let rightViewController = RightViewController()
        let drawerController = V2DrawerController(centerViewController: centerNav, leftDrawerViewController: leftViewController, rightDrawerViewController: rightViewController)

        window.themeChangedHandler = { [weak window, weak drawerController] _ in
            window?.backgroundColor = V2EXColor.colors.v2_backgroundColor
            drawerController?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }

        drawerController.maximumLeftDrawerWidth = 230
        drawerController.maximumRightDrawerWidth = rightViewController.maximumRightDrawerWidth()
        drawerController.openDrawerGestureModeMask = OpenDrawerGestureMode.panningCenterView
        drawerController.closeDrawerGestureModeMask = CloseDrawerGestureMode.all
        window.rootViewController = drawerController

        V2Client.sharedInstance.drawerController = drawerController
        V2Client.sharedInstance.centerViewController = centerNav.viewControllers[0] as? HomeViewController
        V2Client.sharedInstance.centerNavigation = centerNav

        #if DEBUG
        let fpsLabel = V2FPSLabel(frame: CGRect(x: 15, y: window.bounds.height - 40, width: 55, height: 20))
        fpsLabel.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        window.addSubview(fpsLabel)
        #endif

        SVProgressHUD.setForegroundColor(UIColor(white: 1, alpha: 1))
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.15, alpha: 0.85))
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
        SVProgressHUD.setContainerView(window)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        V2EXColor.sharedInstance.refreshStyleIfNeeded()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        guard let window = window, V2Client.sharedInstance.window === window else { return }
        SVProgressHUD.setContainerView(nil)
        V2Client.sharedInstance.window = nil
        V2Client.sharedInstance.drawerController = nil
        V2Client.sharedInstance.centerViewController = nil
        V2Client.sharedInstance.centerNavigation = nil
        self.window = nil
    }
}

class V2Window: UIWindow {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if windowScene?.activationState == .foregroundActive {
            // 后台的临时外观变化不应触发主题更新；返回前台时由 sceneDidBecomeActive 检查。
            V2EXColor.sharedInstance.refreshStyleIfNeeded()
        }
    }
}

final class V2DrawerController: DrawerController {
    // iPhone Duo 默认把状态栏竖排在右侧，关闭竖排栏后状态栏回到顶部、内容占满全屏
    @available(iOS 27.1, *)
    override var preferredVerticalBarBehavior: UIVerticalBarBehavior { .disabled }
}
