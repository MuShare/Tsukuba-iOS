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
        chat?.pictureWidth = object["pictureWidth"].doubleValue
        chat?.pictureHeight = object["pictureHeight"].doubleValue
        return chat!
    }
    
    func isChatSaved(_ cid: String) -> Bool {
        let request = NSFetchRequest<Chat>(entityName: NSStringFromClass(Chat.self))
        request.predicate = NSPredicate(format: "cid=%@", cid)
        return try! context.fetch(request).count > 0
    }
    
    func findByRoom(room: Room, smallerThan seq: Int16 = Int16.max, pageSize: Int = Int.max) -> [Chat] {
        let request = NSFetchRequest<Chat>(entityName: NSStringFromClass(Chat.self))
        request.predicate = NSPredicate(format: "room=%@ and seq<%d", room, seq)
        request.sortDescriptors = [NSSortDescriptor(key: "seq", ascending: false)]
        if pageSize < Int.max {
            request.fetchLimit = pageSize
        }
        if var chats = try? context.fetch(request) {
            chats.sort {
                $0.seq < $1.seq
            }
            return chats
        }
        return []
    }
    
    func deleteAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(Chat.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try! context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
    }
    
}
