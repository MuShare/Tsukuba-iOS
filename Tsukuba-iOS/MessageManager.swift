//
//  MessageManager.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 07/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Alamofire
import SwiftyJSON

class MessageManager: NSObject {

    var dao: DaoManager!
    var pictureUploadingProgress: Double! = 0
    
    static let sharedInstance: MessageManager = {
        let instance = MessageManager()
        return instance
    }()
    
    override init() {
        dao = DaoManager.sharedInstance
    }
    
    func create(title: String, introudction: String, sell: Bool, price: Int, oids: [String], cid: String,
                success: ((String) -> Void)?, fail: (() -> Void)?) {
        
        print(JSON(oids).rawString()!)
        
        let params: Parameters = [
            "cid": cid,
            "title": title,
            "introduction": introudction,
            "oids": JSON(oids).rawString()!,
            "price": price,
            "sell": sell
            
        ]
        
        Alamofire.request(createUrl("api/message/create"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: tokenHeader())
            .responseJSON { (responseObject) in
                let response = Response(responseObject)
                if response.statusOK() {
                    success?(response.getResult()["mid"].stringValue)
                } else {
                    fail?()
                }
        }
    }
    
    func uploadPicture(_ image: UIImage, mid: String, completion: ((Bool, String?) -> Void)?) {
        let data = UIImageJPEGRepresentation(resizeImage(image: image, newWidth: 480)!, 1.0)
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data!, withName: "picture", fileName: UUID().uuidString, mimeType: "image/jpeg")
        },
                         usingThreshold: UInt64.init(),
                         to: createUrl("api/message/picture?mid=" + mid),
                         method: .post,
                         headers: tokenHeader(),
                         encodingCompletion:
            { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        self.pictureUploadingProgress = progress.fractionCompleted
                    }
                    upload.responseJSON { responseObject in
                        let response = Response(responseObject)
                        if response.statusOK() {
                            let path = response.getResult()["path"].stringValue
                            completion?(true, path)
                        } else {
                            completion?(false, nil)
                        }
                    }
                    break
                case .failure(let encodingError):
                    if DEBUG {
                        debugPrint(encodingError)
                    }
                    completion?(false, nil)
            }
        })
        
    }
    
}
