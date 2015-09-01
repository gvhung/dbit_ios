platform :ios, '7.0'
xcodeproj 'OPDBit.xcodeproj'

link_with 'TimeTableWidget'
link_with 'OPDBit Alpha'

pod 'Realm', '0.94.0'
pod 'HMSegmentedControl', '1.5'
pod 'Masonry', '0.6.1'
pod 'MMDrawerController', '0.5.7'
pod 'MZClockView', '1.0.2'
pod 'AFNetworking', '2.5.1'

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        if target.name == "Pods-TimeTableWidget-AFNetworking"
            target.build_configurations.each do |config|
                    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'AF_APP_EXTENSIONS=1']
            end
        end
    end
end

post_install do | installer |
    require 'fileutils'
    #FileUtils.cp_r('Pods/Target Support Files/Pods-Spark/Pods-Spark-acknowledgements.plist', 'Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
