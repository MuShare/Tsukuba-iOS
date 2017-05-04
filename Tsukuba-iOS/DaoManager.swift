//
//  DaoManager.swift
//  Httper
//
//  Created by 李大爷的电脑 on 22/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

import CoreData
import UIKit

class DaoManager: NSObject {
    
    let context: NSManagedObjectContext!
    let categoryDao: CategoryDao!
    let selectionDao: SelectionDao!
    let optionDao: OptionDao!
    
    static let sharedInstance : DaoManager = {
        let instance = DaoManager()
        return instance
    }()
    
    override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        context = delegate.managedObjectContext
        categoryDao = CategoryDao(context)
        selectionDao = SelectionDao(context)
        optionDao = OptionDao(context)
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}
