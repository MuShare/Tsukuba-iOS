import Foundation
import Alamofire
import SwiftyUserDefaults
import SwiftyJSON

class SyncManager {
    
    var dao: DaoManager!
    var config: Config!
    
    static let sharedInstance: SyncManager = {
        let instance = SyncManager()
        return instance
    }()
    
    init() {
        dao = DaoManager.sharedInstance
        config = Config.sharedInstance
    }

    func pullCategory(_ completionHandler: ((Int, Bool) -> Void)?) {
        let params: Parameters = [
            "rev": config.categoryRev
        ]
        Alamofire.request(createUrl("api/category/list"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                let update = result["update"].boolValue
                if update {
                    // Save updated categories to persistent object.
                    let categories = result["categories"].arrayValue
                    for category in categories {
                        _ = self.dao.categoryDao.saveOrUpdate(category, lan: self.config.lan)
                    }
                    // Save global rev
                    self.config.categoryRev = result["rev"].intValue
                }
                completionHandler?(self.config.categoryRev, update)
            } else {
                completionHandler?(-1, false)
            }
        }
    }
    
    func pullSelection(_ completionHandler: ((Int, Bool) -> Void)?) {
        let params: Parameters = [
            "rev": self.config.selectionRev
        ]
        Alamofire.request(createUrl("api/selection/list"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
            .responseJSON { (responseObject) in
                let response = Response(responseObject)
                if response.statusOK() {
                    let result = response.getResult()
                    let update = result["update"].boolValue
                    if update {
                        // Save updated selections to persistent object.
                        let categories = self.dao.categoryDao.findAllDictionary()
                        let selections = result["selections"].arrayValue
                        for object in selections {
                            let cid = object["cid"].stringValue
                            let selection = self.dao.selectionDao.saveOrUpdate(object, lan: self.config.lan)
                            selection.category = categories[cid]
                        }
                        self.dao.saveContext()
                        // Save global rev
                        self.config.selectionRev = result["rev"].intValue
                    }
                    completionHandler?(self.config.selectionRev, update)
                } else {
                    completionHandler?(-1, false)
                }
        }
    }
    
    func pullOption(_ completionHandler: ((Int, Bool) -> Void)?) {
        let params: Parameters = [
            "rev": self.config.optionRev
        ]
        Alamofire.request(createUrl("api/option/list"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
            .responseJSON { (responseObject) in
                let response = Response(responseObject)
                if response.statusOK() {
                    let result = response.getResult()
                    let update = result["update"].boolValue
                    if update {
                        // Save updated options to persistent object.
                        let selections = self.dao.selectionDao.findAllDictionary()
                        let options = result["options"].arrayValue
                        for object in options {
                            let sid = object["sid"].stringValue
                            let option = self.dao.optionDao.saveOrUpdate(object, lan: self.config.lan)
                            option.selection = selections[sid]
                        }
                        self.dao.saveContext()
                        // Save global rev
                        self.config.optionRev = result["rev"].intValue
                    }
                    completionHandler?(self.config.optionRev, update)
                } else {
                    completionHandler?(-1, false)
                }
        }
    }
    
}
