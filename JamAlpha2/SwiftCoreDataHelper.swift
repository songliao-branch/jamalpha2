
import UIKit
import CoreData


class SwiftCoreDataHelper: NSObject {
    
    class func directoryForDatabaseFilename()->NSString{
        return NSHomeDirectory().stringByAppendingString("/Library/Private Documents")
    }
    
    
    class func databaseFilename()->NSString{
        return "database.sqlite";
    }
    
    
    class func managedObjectContext()->NSManagedObjectContext{
        
        var error:NSError? = nil
        
        NSFileManager.defaultManager().createDirectoryAtPath(SwiftCoreDataHelper.directoryForDatabaseFilename() as String, withIntermediateDirectories: true, attributes: nil, error: &error)
        
        let path:NSString = "\(SwiftCoreDataHelper.directoryForDatabaseFilename()) + \(SwiftCoreDataHelper.databaseFilename())"
        
        let url:NSURL = NSURL(fileURLWithPath: path as String)!
        
        let managedModel:NSManagedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)!
        
        var storeCoordinator:NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedModel)
        
        if !(storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error:&error ) != nil){
            if (error != nil){
                println(error!.localizedDescription)
                abort()
            }
        }
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        return managedObjectContext
        
        
    }
    
    class func insertManagedObject(className:NSString, managedObjectConect:NSManagedObjectContext)->AnyObject{
        
        let managedObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(className as String, inManagedObjectContext: managedObjectConect) as! NSManagedObject
        
        return managedObject
        
    }
    
    class func saveManagedObjectContext(managedObjectContext:NSManagedObjectContext)->Bool{
        if managedObjectContext.save(nil){
            return true
        }else{
            return false
        }
    }
    
    
    class func fetchEntities(className:NSString, withPredicate predicate:NSPredicate?, managedObjectContext:NSManagedObjectContext)->NSArray{
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        let entetyDescription:NSEntityDescription = NSEntityDescription.entityForName(className as String, inManagedObjectContext: managedObjectContext)!
        
        fetchRequest.entity = entetyDescription
        if (predicate != nil){
            fetchRequest.predicate = predicate!
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        let items:NSArray = managedObjectContext .executeFetchRequest(fetchRequest, error: nil)!
        
        return items
    }
    
    
}
