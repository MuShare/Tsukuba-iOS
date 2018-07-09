import CoreData
import SwiftyJSON

class RoomDao: DaoTemplate {
    
    func saveOrUpdate(_ object: JSON) -> Room {
        let rid = object["rid"].stringValue
        var room = getByRid(rid)
        if room == nil {
            room = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Room.self),
                                                            into: context) as? Room
        }
        room?.rid = rid
        room?.createAt = {
            if let createAt = object["createAt"].double {
                return Date(timeIntervalSince1970: createAt / 1000)
            }
            if let createAt = object["createAt"]["time"].double {
                return Date(timeIntervalSince1970: createAt / 1000)
            }
            return Date()
        }()
        room?.updateAt = {
            if let updateAt = object["updateAt"].double {
                return Date(timeIntervalSince1970: updateAt / 1000)
            }
            if let updateAt = object["updateAt"]["time"].double {
                return Date(timeIntervalSince1970: updateAt / 1000)
            }
            return Date()
        }()
        room?.chats = object["chats"].int16Value
        room?.lastMessage = object["lastMessage"].stringValue
        room?.creator = object["sender"]["uid"].stringValue == UserManager.shared.uid
        let receiver = object["receiver"]["uid"].stringValue == UserManager.shared.uid ? object["sender"] : object["receiver"]
        room?.receiverId = receiver["uid"].stringValue
        room?.receiverName = receiver["name"].stringValue
        room?.receiverAvatar = receiver["avatar"].stringValue
        return room!
    }
    
    func getByRid(_ rid: String) -> Room? {
        let request = NSFetchRequest<Room>(entityName: NSStringFromClass(Room.self))
        request.predicate = NSPredicate(format: "rid=%@", rid)
        let rooms = try! context.fetch(request)
        if rooms.count == 0 {
            return nil
        }
        return rooms[0]
    }
    
    func getByReceiverId(_ receiverId: String) -> Room? {
        let request = NSFetchRequest<Room>(entityName: NSStringFromClass(Room.self))
        request.predicate = NSPredicate(format: "receiverId=%@", receiverId)
        let rooms = try! context.fetch(request)
        if rooms.count == 0 {
            return nil
        }
        return rooms[0]
    }
    
    func findAll() -> [Room] {
        let request = NSFetchRequest<Room>(entityName: NSStringFromClass(Room.self))
        request.sortDescriptors = [NSSortDescriptor(key: "updateAt", ascending: false)]
        return try! context.fetch(request)
    }
    
    func deleteAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(Room.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try! context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
    }
    
}
