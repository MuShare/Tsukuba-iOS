import CoreData
import SwiftyJSON

class ChatDao: DaoTemplate {
    
    func save(_ object: JSON) -> Chat {
        let chat = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Chat.self),
                                                       into: context) as? Chat
        chat?.cid = object["cid"].stringValue
        chat?.createAt = {
            if let createAt = object["createAt"].double {
                return Date(timeIntervalSince1970: createAt / 1000)
            }
            if let createAt = object["createAt"]["time"].double {
                return Date(timeIntervalSince1970: createAt / 1000)
            }
            return Date()
        }()
        chat?.type = object["type"].int16Value
        chat?.direction = object["direction"].boolValue
        chat?.seq = object["seq"].int16Value
        return chat!
    }
    
    func isChatSaved(_ cid: String) -> Bool {
        let request = NSFetchRequest<Chat>(entityName: NSStringFromClass(Chat.self))
        request.predicate = NSPredicate(format: "cid=%@", cid)
        return try! context.fetch(request).count > 0
    }
    
    func findByRoom(_ room: Room) -> [Chat] {
        let request = NSFetchRequest<Chat>(entityName: NSStringFromClass(Chat.self))
        request.predicate = NSPredicate(format: "room=%@", room)
        request.sortDescriptors = [NSSortDescriptor(key: "seq", ascending: true)]
        return try! context.fetch(request)
    }
    
    func deleteAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(Chat.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try! context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
    }
    
}
