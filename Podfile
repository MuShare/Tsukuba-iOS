use_frameworks!
platform :ios, '9.0'

target 'Tsukuba-iOS' do
    pod 'Alamofire'
    pod 'AXPhotoViewer/Kingfisher'
    pod 'Eureka'
    pod 'ESPullToRefresh'
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'FaveButton'
    pod 'ImageSlideshow/Kingfisher'
    pod 'Kingfisher'
    pod 'NVActivityIndicatorView'
    pod 'R.swift'
    pod 'RxKeyboard'
    pod 'Segmentio'
    pod 'Starscream'
    pod 'SwiftyJSON'
    pod 'SwiftyUserDefaults'
    pod 'SwipeBack'
    pod 'UIImageView+Extension'
    pod 'SnapKit'
end

post_install do |installer|
    targets_4 = ['FaveButton']

    installer.pods_project.targets.each do |target|
        if targets_4.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
        end
    end
end
