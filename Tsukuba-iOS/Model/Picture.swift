import SwiftyJSON

class Picture {
    
    var pid: String!
    var path: String!
    
    init(_ object: JSON) {
        pid = object["pid"].stringValue
        path = object["path"].stringValue
    }
    
    init(pid: String, path: String) {
        self.pid = pid
        self.path = path
    }
    
}
