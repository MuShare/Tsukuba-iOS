use_frameworks!
platform :ios, '9.0'

target 'Tsukuba-iOS' do
    pod 'Alamofire', '~> 4.2'
    pod 'SwiftyUserDefaults', '~> 3'
    pod 'ESPullToRefresh', '~> 2.6'
    pod 'FacebookCore', '~> 0.2'
    pod 'FacebookLogin', '~> 0.2'
    pod 'Kingfisher', '~> 4'
    pod 'UIImageView+Extension', '~> 0.2'
    pod 'Eureka', '~> 4.0'
    pod 'SwiftyJSON', '~> 3.1'
    pod 'SwipeBack', '~> 1.1'
    pod 'ImageSlideshow', '~> 1.3'
    pod 'ImageSlideshow/Kingfisher', '~> 1.3'
    pod 'NVActivityIndicatorView', '~> 4.2'
    pod 'Segmentio', '~> 3.0'
    pod 'FaveButton', '~> 2'
    pod 'UILabel+Copyable', '~> 1.0'
    pod 'Starscream', '~> 3.0'
    pod 'R.swift', '~> 4.0'
    pod 'RxKeyboard', '~> 0.8'
    pod 'AXPhotoViewer/Kingfisher', '~> 1.5'
end

post_install do |installer|
    targets_3 = ['FaveButton']

    installer.pods_project.targets.each do |target|
        if targets_3.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.1'
            end
        end
    end
end
