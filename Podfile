platform :ios, '7.0'
xcodeproj 'OPDBit.xcodeproj'

pod 'Realm', '0.90.6'
pod 'HMSegmentedControl', '1.5'
pod 'Masonry', '0.6.1'
pod 'MMDrawerController', '0.5.7'
pod 'RMDateSelectionViewController', '1.4.3'
pod 'MZClockView', '1.0.2'
pod 'AFNetworking', '2.5.1'
pod 'KVNProgress', '2.2.1'

post_install do | installer |
    require 'fileutils'
    #FileUtils.cp_r('Pods/Target Support Files/Pods-Spark/Pods-Spark-acknowledgements.plist', 'Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
