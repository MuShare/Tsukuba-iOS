import CoreData
import UIKit

class DaoManager {
    
    let context: NSManagedObjectContext!
    let categoryDao: CategoryDao!
    let selectionDao: SelectionDao!
    let optionDao: OptionDao!
    let roomDao: RoomDao!
    let chatDao: ChatDao!
    
    static let shared = DaoManager()
    
    init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        context = delegate.managedObjectContext
        categoryDao = CategoryDao(context)
        selectionDao = SelectionDao(context)
        optionDao = OptionDao(context)
        roomDao = RoomDao(context)
        chatDao = ChatDao(context)
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
