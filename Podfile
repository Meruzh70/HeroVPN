# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

project 'HeroVPN.xcodeproj'

target 'HeroVPNiOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HeroVPNiOS
  pod 'SwiftGen', '~> 6.6.2'
  pod 'SwiftyJSON', '~> 5.0.1'
  pod 'ProgressHUD', '~> 14.1.1'
  pod 'SwiftGifOrigin', '~> 1.7.0'
  pod 'Alamofire', '~> 5.6.4'
  pod 'Firebase/Analytics', '10.29.0'
  pod 'Firebase/Messaging', '10.29.0'
  pod 'Firebase/Crashlytics', '10.29.0'


  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        end
      end
    end
  end
end

target 'HeroVPNmacOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HeroVPNmacOS
end

target 'HeroVPNmacOSLoginItemHelper' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HeroVPNmacOSLoginItemHelper

end

target 'HeroVPNNetworkExtensioniOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for HeroVPNNetworkExtensioniOS

end

target 'HeroVPNNetworkExtensionmacOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HeroVPNNetworkExtensionmacOS

end

