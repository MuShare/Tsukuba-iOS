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
    pod 'NVActivityIndicatorView', '~> 3.6'
    pod 'Segmentio', '~> 2.1'
    pod 'FaveButton', '~> 2'
    pod 'RxKeyboard', '~> 0.8'
end

post_install do |installer|
    targets_4 = ['Eureka']

    installer.pods_project.targets.each do |target|
        if targets_4.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
