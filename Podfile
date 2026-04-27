# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Football2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Football2

  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'MBProgressHUD'
  pod 'IQKeyboardManagerSwift', '~> 7.0.3'
  pod 'SDWebImage'
  pod 'Google-Mobile-Ads-SDK'
  pod 'FirebaseAnalytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'
  pod 'Firebase/Performance'
  pod 'Firebase/Crashlytics'
  pod 'lottie-ios'
#  pod 'GradientLoadingBar'
  pod 'Toast-Swift'
#  pod 'SwiftSoup'
  pod 'CHIPageControl/Jalapeno'
  pod 'SkeletonView'
  pod 'AWSMobileClient', '~> 2.6.13'
  pod 'AWSS3'
  pod "UPCarouselFlowLayout"
  pod 'SVProgressHUD'
  pod 'Toast'
  pod 'MarqueeLabel'
  pod 'SideMenu'

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.1'
      end
    end
  end
end
