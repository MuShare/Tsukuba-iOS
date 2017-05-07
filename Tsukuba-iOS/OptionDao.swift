//
//  OptionDao.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import CoreData

class OptionDao: DaoTemplate {
    
    func saveOrUpdate(_ object: NSObject) -> Option {
        let oid = object.value(forKey: "oid") as! String
        var option = getByOid(oid)
        if option == nil {
            option = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Option.self),
                                                         into: context) as? Option
        }
        option?.oid = oid
        option?.createAt = object.value(forKey: "createAt") as! Int32
        option?.enable = object.value(forKey: "enable") as! Bool
        option?.identifier = object.value(forKey: "identifier") as? String
        option?.name = object.value(forKey: "name") as? String
        option?.priority = object.value(forKey: "priority") as! Int16
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
