import CoreData
import SwiftyJSON

class SelectionDao: DaoTemplate {

    func saveOrUpdate(_ object: JSON, lan: String) -> Selection {
        let sid = object["sid"].stringValue
        var selection = getBySid(sid)
        if selection == nil {
            selection = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Selection.self),
                                                            into: context) as? Selection
        }
        selection?.sid = sid
        selection?.createAt = object["createAt"].int16Value
        selection?.enable = object["enable"].boolValue
        selection?.identifier = object["identifier"].stringValue
        selection?.name = object["name"][lan].stringValue
        selection?.priority = object["priority"].int16Value
        return selection!
    }
    
    func findEnable() -> [Selection] {
        let request = NSFetchRequest<Selection>(entityName: NSStringFromClass(Selection.self))
        request.predicate = NSPredicate(format: "enable=true")
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        return try! context.fetch(request)
    }
    
    func findEnableByCategory(_ category: Category) -> [Selection] {
        let request = NSFetchRequest<Selection>(entityName: NSStringFromClass(Selection.self))
        request.predicate = NSPredicate(format: "enable=true and category=%@", category)
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        return try! context.fetch(request)
    }
    
    func findAll() -> [Selection] {
        let request = NSFetchRequest<Selection>(entityName: NSStringFromClass(Selection.self))
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        return try! context.fetch(request)
    }
    
    func getBySid(_ sid: String) -> Selection? {
        let request = NSFetchRequest<Selection>(entityName: NSStringFromClass(Selection.self))
        request.predicate = NSPredicate(format: "sid=%@", sid)
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
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
