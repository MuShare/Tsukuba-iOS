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

class SyncManager: NSObject {
    
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
    
    override init() {
        dao = DaoManager.sharedInstance
    }

    func pullCategory(_ completionHandler: ((Int) -> Void)?) {
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
                let update = result?["update"] as! Bool
                if !update {
                    return
                }
                // Save updated categories to persistent object.
                let categories = result?["categories"] as! [NSObject]
                for category in categories {
                    _ = self.dao.categoryDao.saveOrUpdate(category)
                }
                // Save global rev
                self.categoryRev = result?["rev"] as! Int
                completionHandler?(self.categoryRev)
            } else {
                completionHandler?(-1)
            }
        }
    }
    
    func pullSelection(_ completionHandler: ((Int) -> Void)?) {
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
                    let update = result?["update"] as! Bool
                    if !update {
                        return
                    }
                    // Save updated categories to persistent object.
                    let categories = self.dao.categoryDao.findAllDictionary()
                    let selections = result?["selections"] as! [NSObject]
                    for selection in selections {
                        let cid = selection.value(forKey: "cid") as! String
                        categories[cid]?.addToSelections(self.dao.selectionDao.saveOrUpdate(selection))
                    }
                    self.dao.saveContext()
                    // Save global rev
                    self.selectionRev = result?["rev"] as! Int
                    completionHandler?(self.selectionRev)
                } else {
                    completionHandler?(-1)
                }
        }
    }
    
}
