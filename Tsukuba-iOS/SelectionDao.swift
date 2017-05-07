//
//  SelectionDao.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import CoreData

class SelectionDao: DaoTemplate {

    func saveOrUpdate(_ object: NSObject) -> Selection {
        let sid = object.value(forKey: "sid") as! String
        var selection = getBySid(sid)
        if selection == nil {
            selection = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Selection.self),
                                                            into: context) as? Selection
        }
        selection?.sid = sid
        selection?.createAt = object.value(forKey: "createAt") as! Int32
        selection?.enable = object.value(forKey: "enable") as! Bool
        selection?.identifier = object.value(forKey: "identifier") as? String
        selection?.name = object.value(forKey: "name") as? String
        selection?.priority = object.value(forKey: "priority") as! Int16
        return selection!
    }
    
    func findEnable() -> [Selection] {
        let request = NSFetchRequest<Selection>(entityName: NSStringFromClass(Selection.self))
        request.predicate = NSPredicate(format: "enable=true")
        return try! context.fetch(request)
    }
    
    func findAll() -> [Selection] {
        let request = NSFetchRequest<Selection>(entityName: NSStringFromClass(Selection.self))
        return try! context.fetch(request)
    }
    
    func getBySid(_ sid: String) -> Selection? {
        let request = NSFetchRequest<Selection>(entityName: NSStringFromClass(Selection.self))
        request.predicate = NSPredicate(format: "sid=%@", sid)
        let selections = try! context.fetch(request)
        if selections.count == 0 {
            return nil
        }
        return selections[0]
    }
    
    func findAllDictionary() -> [String: Selection] {
        var selections = [String: Selection]()
        for selection in findAll() {
            selections[selection.sid!] = selection
        }
        return selections
    }
    
}
