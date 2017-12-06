import CoreData
import SwiftyJSON

class CategoryDao: DaoTemplate {
    
    func saveOrUpdate(_ object: JSON, lan: String) -> Category {
        let cid = object["cid"].stringValue
        var category = getByCid(cid)
        if category == nil {
            category = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Category.self),
                                                           into: context) as? Category
        }
        category?.cid = cid
        category?.createAt = object["createAt"].int16Value
        category?.enable = object["enable"].boolValue
        category?.icon = object["icon"].stringValue
        category?.identifier = object["identifier"].stringValue
        category?.name = object["name"][lan].stringValue
        category?.priority = object["priority"].int16Value
        self.saveContext()
        return category!
    }
    
    func findEnable() -> [Category] {
        let request = NSFetchRequest<Category>(entityName: NSStringFromClass(Category.self))
        request.predicate = NSPredicate(format: "enable=true")
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        return try! context.fetch(request)
    }
    
    func findAll() -> [Category] {
        let request = NSFetchRequest<Category>(entityName: NSStringFromClass(Category.self))
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        return try! context.fetch(request)
    }
    
    func getByCid(_ cid: String) -> Category? {
        let request = NSFetchRequest<Category>(entityName: NSStringFromClass(Category.self))
        request.predicate = NSPredicate(format: "cid=%@", cid)
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
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
