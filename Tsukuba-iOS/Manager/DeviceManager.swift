import Alamofire
import SwiftyUserDefaults

class DeviceManager {

    static let shared = DeviceManager()

    init() {

    }
    
    func uploadDeviceToken(_ token: String, completion: ((Bool) -> Void)?) {
        let params: Parameters = [
            "deviceToken": token
        ]
        Alamofire.request(createUrl("api/user/deviceToken"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: Config.shared.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            completion?(response.statusOK() ? response.getResult()["success"].boolValue : false)
        }
    }
    
}
