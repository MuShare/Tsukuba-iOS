import Alamofire
import SwiftyUserDefaults

class DeviceManager {
    
    var config: Config!
    
    static let sharedInstance: DeviceManager = {
        let instance = DeviceManager()
        return instance
    }()
    
    init() {
        config = Config.sharedInstance
    }
    
    func uploadDeviceToken(_ token: String, completion: ((Bool) -> Void)?) {
        let params: Parameters = [
            "deviceToken": token
        ]
        Alamofire.request(createUrl("api/user/deviceToken"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            completion?(response.statusOK() ? response.getResult()["success"].boolValue : false)
        }
    }
    
}
