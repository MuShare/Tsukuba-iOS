//
//  Selection+CoreDataProperties.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Foundation
import CoreData


extension Selection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Selection> {
        return NSFetchRequest<Selection>(entityName: "Selection")
    }

    @NSManaged public var createAt: Int32
    @NSManaged public var enable: Bool
    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var priority: Int16
    @NSManaged public var sid: String?
    @NSManaged public var category: Category?
    @NSManaged public var options: NSSet?

}

// MARK: Generated accessors for options
extension Selection {

    @objc(addOptionsObject:)
    @NSManaged public func addToOptions(_ value: Option)

    @objc(removeOptionsObject:)
    @NSManaged public func removeFromOptions(_ value: Option)

    @objc(addOptions:)
    @NSManaged public func addToOptions(_ values: NSSet)

    @objc(removeOptions:)
    @NSManaged public func removeFromOptions(_ values: NSSet)

}
