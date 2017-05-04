//
//  Option+CoreDataProperties.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Foundation
import CoreData


extension Option {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Option> {
        return NSFetchRequest<Option>(entityName: "Option")
    }

    @NSManaged public var createAt: Int32
    @NSManaged public var enable: Bool
    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var oid: String?
    @NSManaged public var priority: Int16
    @NSManaged public var selection: Selection?

}
