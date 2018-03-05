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
        room?.createAt = NSDate(timeIntervalSince1970: object["createAt"].doubleValue / 1000)
        room?.updateAt = NSDate(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
        room?.chats = object["chats"].int16Value
        room?.lastMessage = object["lastMessage"].stringValue
        room?.creator = object["creator"].boolValue
        let receiver = object[(room?.creator)! ? "receiver" : "sender"]
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
    
}
