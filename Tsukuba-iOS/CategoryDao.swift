//
//  CategoryDao.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import CoreData

class CategoryDao: DaoTemplate {
    
    func saveOrUpdate(_ object: NSObject) -> Category {
        let cid = object.value(forKey: "cid") as! String
        var category = getByCid(cid)
        if category == nil {
            category = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Category.self),
                                                           into: context) as? Category
        }
        category?.cid = cid
        category?.createAt = object.value(forKey: "createAt") as! Int32
        category?.enable = object.value(forKey: "enable") as! Bool
        category?.icon = object.value(forKey: "icon") as? String
        category?.identifier = object.value(forKey: "identifier") as? String
        category?.name = object.value(forKey: "name") as? String
        category?.priority = object.value(forKey: "priority") as! Int16
        self.saveContext()
        return category!
    }
    
    func findEnable() -> [Category] {
        let request = NSFetchRequest<Category>(entityName: NSStringFromClass(Category.self))
        request.predicate = NSPredicate(format: "enable=true")
        return try! context.fetch(request)
    }
    
    func findAll() -> [Category] {
        let request = NSFetchRequest<Category>(entityName: NSStringFromClass(Category.self))
        return try! context.fetch(request)
    }
    
    func getByCid(_ cid: String) -> Category? {
        let request = NSFetchRequest<Category>(entityName: NSStringFromClass(Category.self))
        request.predicate = NSPredicate(format: "cid=%@", cid)
        let categories = try! context.fetch(request)
        if categories.count == 0 {
            return nil
        }
        return categories[0]
    }
    
    func findAllDictionary() -> [String: Category] {
        var categories = [String: Category]()
        for category in findAll() {
            categories[category.cid!] = category
        }
        return categories
    }

}
