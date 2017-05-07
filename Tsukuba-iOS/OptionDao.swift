//
//  OptionDao.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import CoreData
import SwiftyJSON

class OptionDao: DaoTemplate {
    
    func saveOrUpdate(_ object: JSON) -> Option {
        let oid = object["oid"].stringValue
        var option = getByOid(oid)
        if option == nil {
            option = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Option.self),
                                                         into: context) as? Option
        }
        option?.oid = oid
        option?.createAt = object["createAt"].int16Value
        option?.enable = object["enable"].boolValue
        option?.identifier = object["identifier"].stringValue
        option?.name = object["name"].stringValue
        option?.priority = object["priority"].int16Value
        return option!
    }
    
    func findEnable() -> [Option] {
        let request = NSFetchRequest<Option>(entityName: NSStringFromClass(Option.self))
        request.predicate = NSPredicate(format: "enable=true")
        return try! context.fetch(request)
    }
    
    func findEnableBySelection(_ selection: Selection) -> [Option] {
        let request = NSFetchRequest<Option>(entityName: NSStringFromClass(Option.self))
        request.predicate = NSPredicate(format: "enable=true and selection=%@", selection)
        return try! context.fetch(request)
    }
    
    func getByOid(_ oid: String) -> Option? {
        let request = NSFetchRequest<Option>(entityName: NSStringFromClass(Option.self))
        request.predicate = NSPredicate(format: "oid=%@", oid)
        let options = try! context.fetch(request)
        if options.count == 0 {
            return nil
        }
        return options[0]
    }

}
