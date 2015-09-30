
import UIKit
import CoreData


class SwiftCoreDataHelper: NSObject {
    
    class func directoryForDatabaseFilename() -> NSString{
        return NSHomeDirectory().stringByAppendingString("/Library/Private Documents")
    }
    
    
    class func databaseFilename() -> NSString{
        return "database.sqlite"
    }
    
    
    class func managedObjectContext() -> NSManagedObjectContext{
         
        try! NSFileManager.defaultManager().createDirectoryAtPath(SwiftCoreDataHelper.directoryForDatabaseFilename() as String, withIntermediateDirectories: true, attributes: nil)
        
        let path:NSString = "\(SwiftCoreDataHelper.directoryForDatabaseFilename()) + \(SwiftCoreDataHelper.databaseFilename())"
        
        let url: NSURL = NSURL(fileURLWithPath: path as String)
        
        let managedModel: NSManagedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)!
        
        let storeCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedModel)
        
        do {
            try storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch  {
            print(error)
            abort()
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        return managedObjectContext
        
        
    }
    
    class func insertManagedObject(className:NSString, managedObjectConect:NSManagedObjectContext)->AnyObject{
        
        let managedObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(className as String, inManagedObjectContext: managedObjectConect) 
        
        return managedObject
        
    }
    
    class func saveManagedObjectContext(managedObjectContext: NSManagedObjectContext)->Bool{
        guard managedObjectContext.hasChanges else {
            return false
        }
        do {
            try managedObjectContext.save()
            return true
        } catch {
            fatalError("Cannot save in core data\(error)")
        }
    }
    
    
    class func fetchEntities(className: NSString, withPredicate predicate: NSPredicate?, managedObjectContext: NSManagedObjectContext)->NSArray{
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        let entityDescription: NSEntityDescription = NSEntityDescription.entityForName(className as String, inManagedObjectContext: managedObjectContext)!
        
        fetchRequest.entity = entityDescription
        if (predicate != nil){
            fetchRequest.predicate = predicate!
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        let items: NSArray = try! managedObjectContext .executeFetchRequest(fetchRequest)
        
        return items
    }
    
    
}
