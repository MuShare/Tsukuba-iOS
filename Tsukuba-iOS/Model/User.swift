import SwiftyJSON

class User {
    
    var uid: String!
    var name: String!
    var avatar: String!
    var createAt: Date!
    var type: String!
    var identifier: String!
    var contact: String!
    var address: String!
    var level: Int!
    
    init(simpleUser: JSON) {
        uid = simpleUser["uid"].stringValue
        name = simpleUser["name"].stringValue
        avatar = simpleUser["avatar"].stringValue
    }
    
    init(user: JSON) {
        uid = user["uid"].stringValue
        name = user["name"].stringValue
        avatar = user["avatar"].stringValue
        createAt = Date(timeIntervalSince1970: user["createAt"].doubleValue / 1000)
        type = user["type"].stringValue
        identifier = user["identifier"].stringValue
        contact = user["contact"].stringValue
        address = user["address"].stringValue
        level = user["level"].intValue
    }
    
    init(uid: String, name: String, avatar: String, createAt: Date, type: String, identifier: String, contact: String, address: String, level: Int) {
        self.uid = uid
        self.name = name
        self.createAt = createAt
        self.type = type
        self.identifier = identifier
        self.contact = contact
        self.address = address
        self.level = level
    }
    
}
