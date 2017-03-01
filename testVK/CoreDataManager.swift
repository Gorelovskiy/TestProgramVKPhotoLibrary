import CoreData
import Foundation

class CoreDataManager {
    
    // Singleton
    static let instance = CoreDataManager()
    
    // Entity for Name
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "G.test2UICollectionView" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "testVK", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "testVK")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //--------------------------------------------------------------
    //    Func for Download information about Albums from CoreData
    //--------------------------------------------------------------
    func DownloadInformationAboutAlbum(delete:Bool = false, albumID:String = "") -> [album]{
        var Albums = [album()]
        Albums.removeAll()
        
        let context = CoreDataManager.instance.managedObjectContext

        let defaults = UserDefaults.standard
        let user = defaults.string(forKey: "userID")
        
        // To obtain data about AlbumName and album photo URL
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        var sortDescriptorUserID = NSSortDescriptor(key: "userID", ascending: true)
        var resultPredicate = NSPredicate(format: "userID = %@", user!)
        
        if delete == true{
            sortDescriptorUserID = NSSortDescriptor(key: "albumID", ascending: true)
            resultPredicate = NSPredicate(format: "albumID = %@", albumID)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptorUserID]
        fetchRequest.predicate = resultPredicate
        do {
            let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest)
            for result in results as! [Album] {
                
                if delete == false{
                    Albums.append(album.init(userID: user!
                                                       ,albumID: result.albumID!
                                                       ,albumName: result.albumName!
                                                       ,albumPhoto: result.albumPhoto!
                                                       ,dateUpdate: result.dateUpdate!
                    ))
                }
                else{
                context.delete(result as NSManagedObject)
                }
            }
            return Albums
        } catch {
            print(error)
        }
        
        return Albums
        
    }
    //--------------------------------------------------------------
    //    Func for Download information about Photos from CoreData
    //--------------------------------------------------------------

    func DownloadInformationAboutPhotos(delete:Bool = false, albumID:String = "")->[photo]{
        var Photo = [photo()]
        Photo.removeAll()
        
        let context = CoreDataManager.instance.managedObjectContext
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let sortDescriptorUserID = NSSortDescriptor(key: "idAlbum", ascending: true)
        let resultPredicate = NSPredicate(format: "idAlbum = %@", albumID)
        
        
        
        fetchRequest.sortDescriptors = [sortDescriptorUserID]
        fetchRequest.predicate = resultPredicate
        do {
            let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest)
            for result in results as! [Photo] {
                if delete == false{
                Photo.append(photo.init(   idPhoto: result.idPhoto!
                    ,photoReference: result.photoReference!
                    ,miniPhotoReference: result.miniPhotoReference!
                    ,photoName: result.photoName!
                    ,photoDate: result.photoDate!
                    ,photoLocLONG: result.photoLocLONG!
                    ,photoLocLAT: result.photoLocLAT!
                ))
                }
                else{
                    context.delete(result as NSManagedObject)
                }
            }
            
            
        } catch { print(error) }
        return Photo
        
    }
    
    
}
