import CoreData
import SwiftyJSON

class ChatDao: DaoTemplate {
    
    func save(_ object: JSON) -> Chat {
        let chat = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Chat.self),
                                                       into: context) as? Chat
        chat?.cid = object["cid"].stringValue
        chat?.createAt = NSDate(timeIntervalSince1970: object["createAt"].doubleValue / 1000)
        chat?.type = object["type"].int16Value
        chat?.direction = object["direction"].boolValue
        chat?.seq = object["seq"].int16Value
        return chat!
    }
    
    func findByRoom(_ room: Room) -> [Chat] {
        let request = NSFetchRequest<Chat>(entityName: NSStringFromClass(Chat.self))
        request.predicate = NSPredicate(format: "room=%@", room)
        request.sortDescriptors = [NSSortDescriptor(key: "seq", ascending: true)]
        return try! context.fetch(request)
    }
    
}