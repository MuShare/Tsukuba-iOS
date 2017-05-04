//
//  Category+CoreDataProperties.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var cid: String?
    @NSManaged public var createAt: Int32
    @NSManaged public var enable: Bool
    @NSManaged public var icon: String?
    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var priority: Int16
    @NSManaged public var selections: NSSet?

}

// MARK: Generated accessors for selections
extension Category {

    @objc(addSelectionsObject:)
    @NSManaged public func addToSelections(_ value: Selection)

    @objc(removeSelectionsObject:)
    @NSManaged public func removeFromSelections(_ value: Selection)

    @objc(addSelections:)
    @NSManaged public func addToSelections(_ values: NSSet)

    @objc(removeSelections:)
    @NSManaged public func removeFromSelections(_ values: NSSet)

}
