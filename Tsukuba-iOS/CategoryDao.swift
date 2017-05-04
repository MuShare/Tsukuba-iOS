//
//  CategoryDao.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import CoreData

class CategoryDao: DaoTemplate {
    
    func save(object: NSObject) -> Category {
        let category = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Category.self),
                                                           into: context) as! Category
        category.cid = object.value(forKey: "cid") as? String
        category.createAt = object.value(forKey: "createAt") as! Int32
        category.enable = object.value(forKey: "enable") as! Bool
        category.icon = object.value(forKey: "icon") as? String
        category.identifier = object.value(forKey: "identifier") as? String
        category.name = object.value(forKey: "name") as? String
        category.priority = object.value(forKey: "priority") as! Int16
        self.saveContext()
        return category
    }

}
