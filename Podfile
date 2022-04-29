platform :ios, '14.0'

plugin 'cocoapods-acknowledgements'

target 'Bahnhofsfotos' do
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Bahnhofsfotos
  pod 'Alamofire', '~> 5.2'
  pod 'CPDAcknowledgements', '~> 1.0'
  pod 'Eureka', '~> 5.3'
  pod 'FBAnnotationClusteringSwift', :git => 'https://github.com/666tos/FBAnnotationClusteringSwift'
  pod 'FontAwesomeIconFactory', '~> 3.0'
  pod 'FontAwesomeKit.Swift', '~> 1.0'
  pod 'ImagePicker', :git => 'https://github.com/hyperoslo/ImagePicker'
  pod 'Lightbox', '~> 2.5'
#  pod 'SQLite.swift', '~> 0.12'
  pod 'SwiftLint', '~> 0.40'
#  pod 'SwiftyJSON', '~> 5.0'
#  pod 'SwiftyUserDefaults', '~> 5.0'
  pod 'Toast-Swift', '~> 5.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
