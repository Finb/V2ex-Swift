platform:ios,'13.0'
inhibit_all_warnings!
use_modular_headers!

def pods
  pod 'SnapKit'
  pod 'Alamofire'
  pod 'ObjectMapper'
  pod 'AlamofireObjectMapper'
  pod 'Ji'
  pod 'DrawerController'
  pod 'Kingfisher', '~> 7.11.0'
  pod 'KeychainSwift'
  pod 'KVOController'
  pod 'YYText'
  pod 'FXBlurView'
  pod 'SVProgressHUD'
  pod 'MJRefresh', '~> 3.1.15.7'
  pod 'CXSwipeGestureRecognizer'
  pod '1PasswordExtension'
  pod 'Shimmer'
  pod 'FDFullscreenPopGesture'
  pod 'Moya/RxSwift'
  pod 'SwiftyJSON', '~> 4.3'
end

target 'V2ex-Swift' do
  pods
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      # 将三方库的Deploy版本号都提到iOS11，隐藏编译过程中相关的Deprecated警告及其他警告
      target.build_configurations.each do |config|
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        # https://stackoverflow.com/questions/63056454/xcode-12-deployment-target-warnings-when-using-cocoapods
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 11.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
      end
      if target.name == 'Ji' or target.name == 'Moya'  or target.name == 'Result'
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.2'
        end
      end
      if target.name == 'DrawerController'
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.0'
        end
      end
    end
  end
end
