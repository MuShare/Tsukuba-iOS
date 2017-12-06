import SwiftyJSON

class Message {

    var mid: String!
    var title: String!
    var cover: String!
    var createAt: Date!
    var updateAt: Date!
    var price: Int!
    var cid: String!
    var enable: Bool
    var seq: Int!
    
    var favorite: Bool
    var favorites: Int!
    
    var introduction: String?
    var author: User?
    var pictures: [Picture] = []
    var options: [Option] = []
    
    init(_ object: JSON) {
        mid = object["mid"].stringValue
        title = object["title"].stringValue
        cover = object["cover"].stringValue
        createAt = Date(timeIntervalSince1970: object["createAt"].doubleValue / 1000)
        updateAt = Date(timeIntervalSince1970: object["updateAt"].doubleValue / 1000)
        price = object["price"].intValue
        cid = object["cid"].stringValue
        enable = object["enable"].boolValue
        seq = object["seq"].intValue
        
        // Detail info
        introduction = object["introduction"].string
        author = User(simpleUser: object["author"])
        favorite = object["favorite"].boolValue
        favorites = object["favorites"].intValue
        
        // Pictures
        let picturesJOSONArray = object["pictures"].arrayValue;
        if picturesJOSONArray.count > 0 {
            for picture in picturesJOSONArray {
                pictures.append(Picture(picture))
            }
        }
        
        // Options
        let oidsJSONArray = object["options"].arrayValue
        if oidsJSONArray.count > 0 {
            var oids: [String] = []
            for oid in oidsJSONArray {
                oids.append(oid.stringValue)
            }
            for option in DaoManager.sharedInstance.optionDao.findInOids(oids) {
                options.append(option)
            }
        }
    }
    
}
