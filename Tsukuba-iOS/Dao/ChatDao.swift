import CoreData
import SwiftyJSON

class ChatDao: DaoTemplate {
    
    func save(_ object: JSON) -> Chat {
        let chat = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Chat.self),
                                                       into: context) as? Chat
        chat?.cid = object["cid"].stringValue
        chat?.createAt = object["createAt"].int16Value
        chat?.type = object["type"].int16Value
        chat?.direction = object["direction"].boolValue
        chat?.seq = object["seq"].int16Value
        return chat!
    }
    
}
