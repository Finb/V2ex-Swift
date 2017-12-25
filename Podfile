platform:ios,'9.0'
inhibit_all_warnings!
use_frameworks!

def pods
    pod 'SnapKit'
    pod 'Alamofire'
    pod 'ObjectMapper'
    pod 'AlamofireObjectMapper'
    pod 'Ji'
    pod 'DrawerController'
    pod 'Kingfisher'
    pod 'KeychainSwift'
    pod 'KVOController'
    pod 'YYText'
    pod 'FXBlurView'
    pod 'SVProgressHUD'
    pod 'MJRefresh'
    pod 'CXSwipeGestureRecognizer'
    pod '1PasswordExtension'
    pod 'Shimmer'
    pod 'FDFullscreenPopGesture'
    pod 'Moya/RxSwift', '~> 8.0.5'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'DeviceKit'
end

target 'V2ex-Swift' do
    pods
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if target.name == 'Moya' or target.name == 'RxSwift'
                target.build_configurations.each do |config|
                    config.build_settings['SWIFT_VERSION'] = '3.2'
                end
            end
        end
    end
end
