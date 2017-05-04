//
//  SyncManager.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Foundation
import Alamofire
import DGElasticPullToRefresh

class SyncManager: NSObject {
    
    var dao: DaoManager!
    
    static let sharedInstance: SyncManager = {
        let instance = SyncManager()
        return instance
    }()
    
    override init() {
        dao = DaoManager.sharedInstance
    }

    func pullCategory(_ completionHandler: ((Int) -> Void)?) {
        let params: Parameters = [
            "rev": categoryRev()
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
                    _ = self.dao.categoryDao.saveOrUpdate(object: category)
                }
                // Save global rev
                let rev = result?["rev"] as! Int
                setCategoryRev(rev)
                completionHandler?(rev)
            } else {
                completionHandler?(-1)
            }
        }
    }
    
}
