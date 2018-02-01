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
        room?.createAt = object["createAt"].int16Value
        room?.updateAt = object["updateAt"].int16Value
        let receiver = object["receiver"]
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
    
}
