platform :ios, '9.0'

plugin 'cocoapods-acknowledgements'

target 'Bahnhofsfotos' do
  use_frameworks!

  # Pods for Bahnhofsfotos
  pod 'AAShareBubbles', '~> 1.2'
  pod 'Alamofire', '~> 4.6'
  pod 'CPDAcknowledgements', '~> 1.0'
  pod 'Eureka', '~> 4.0'
  pod 'FBAnnotationClusteringSwift', :git => 'https://github.com/666tos/FBAnnotationClusteringSwift'
  pod 'FirebaseAuth', '~> 4.4'
  pod 'FirebaseCore', '~> 4.0'
  pod 'FirebaseDatabase', '~> 4.1'
  pod 'FirebaseMessaging', '~> 2.0'
  pod 'FontAwesomeIconFactory', '~> 3.0'
  pod 'FontAwesomeKit.Swift', '~> 0.4'
  pod 'GoogleSignIn', '~> 4.1'
  pod 'ImagePicker', :git => 'https://github.com/hyperoslo/ImagePicker'
  pod 'JSQMessagesViewController', '~> 7.3'
  pod 'SQLite.swift', '~> 0.11'
  pod 'SwiftLint', '~> 0.23'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'SwiftyUserDefaults', '~> 3.0'
  pod 'Toast-Swift', '~> 3.0'

end

post_install do |installer|
    # List of Swift 4 targets
    swift4_targets = []
    
    installer.pods_project.targets.each do |target|
        if swift4_targets.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
