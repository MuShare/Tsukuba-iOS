//
//  SyncManager.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyUserDefaults
import SwiftyJSON

class SyncManager {
    
    var dao: DaoManager!
    
    var categoryRev: Int {
        set(value) {
            Defaults[.categoryRev] = value
        }
        get {
            return Defaults[.categoryRev] ?? 0
        }
    }
    
    var selectionRev: Int {
        set(value) {
            Defaults[.selectionRev] = value
        }
        get {
            return Defaults[.selectionRev] ?? 0
        }
    }
    
    var optionRev: Int {
        set(value) {
            Defaults[.optionRev] = value
        }
        get {
            return Defaults[.optionRev] ?? 0
        }
    }
    
    static let sharedInstance: SyncManager = {
        let instance = SyncManager()
        return instance
    }()
    
    init() {
        dao = DaoManager.sharedInstance
    }

    func pullCategory(_ completionHandler: ((Int, Bool) -> Void)?) {
        let params: Parameters = [
            "rev": self.categoryRev
        ]
        Alamofire.request(createUrl("api/category/list"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: tokenHeader())
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                let update = result["update"].boolValue
                if update {
                    // Save updated categories to persistent object.
                    let categories = result["categories"].arrayValue
                    for category in categories {
                        _ = self.dao.categoryDao.saveOrUpdate(category)
                    }
                    // Save global rev
                    self.categoryRev = result["rev"].intValue
                }
                completionHandler?(self.categoryRev, update)
            } else {
                completionHandler?(-1, false)
            }
        }
    }
    
    func pullSelection(_ completionHandler: ((Int, Bool) -> Void)?) {
        let params: Parameters = [
            "rev": self.selectionRev
        ]
        Alamofire.request(createUrl("api/selection/list"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: tokenHeader())
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
                            let selection = self.dao.selectionDao.saveOrUpdate(object)
                            selection.category = categories[cid]
                        }
                        self.dao.saveContext()
                        // Save global rev
                        self.selectionRev = result["rev"].intValue
                    }
                    completionHandler?(self.selectionRev, update)
                } else {
                    completionHandler?(-1, false)
                }
        }
    }
    
    func pullOption(_ completionHandler: ((Int, Bool) -> Void)?) {
        let params: Parameters = [
            "rev": self.optionRev
        ]
        Alamofire.request(createUrl("api/option/list"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: tokenHeader())
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
                            let option = self.dao.optionDao.saveOrUpdate(object)
                            option.selection = selections[sid]
                        }
                        self.dao.saveContext()
                        // Save global rev
                        self.optionRev = result["rev"].intValue
                    }
                    completionHandler?(self.optionRev, update)
                } else {
                    completionHandler?(-1, false)
                }
        }
    }
    
}
