import UIKit
import SwiftyVK
import CoreData
import Kingfisher

class PhotosViewController: UITableViewController {
    
    
    var albumID = ""
    var Photo = [Structurs.photo()]
    
    var imagesDirectoryPath:String!
    var images: [UIImage]!
    var titles:[String]!
    var markerFirstLoadController = false
    //---------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        DownloadInformationAboutPhotos()
    }
    //---------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //---------------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Photo.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoTableViewCell
        cell.imagePhoto.kf.setImage(with: URL(string: Photo[indexPath.row].miniPhotoReference))
        cell.namePhoto?.text = Photo[indexPath.row].photoName
        cell.datePhoto?.text = Photo[indexPath.row].photoDate
        cell.imagePhoto.layer.cornerRadius = 30.0
        cell.imagePhoto.clipsToBounds = true
        
        return cell
    }
    //---------------------------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto"{
             if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! PhotoViewController
                destinationController.adressPhoto = Photo[indexPath.row].photoReference
                destinationController.photoLONG = Photo[indexPath.row].photoLocLONG
                destinationController.photoLAT = Photo[indexPath.row].photoLocLAT
                destinationController.photoIdentifier = Photo[indexPath.row].idPhoto
                destinationController.namePhoto = Photo[indexPath.row].photoName
                destinationController.datePhoto = Photo[indexPath.row].photoDate
                
            }
        }
    }
    //---------------------------------------------------------------------------------------
    func DownloadInformationAboutPhotos(){
        Photo.removeAll()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let sortDescriptorUserID = NSSortDescriptor(key: "idAlbum", ascending: true)
        let resultPredicate = NSPredicate(format: "idAlbum = %@", albumID)
        
        fetchRequest.sortDescriptors = [sortDescriptorUserID]
        fetchRequest.predicate = resultPredicate
        do {
            let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest)
            for result in results as! [Photo] {
                Photo.append(Structurs.photo.init(   idPhoto: result.idPhoto!
                    ,photoReference: result.photoReference!
                    ,miniPhotoReference: result.miniPhotoReference!
                    ,photoName: result.photoName!
                    ,photoDate: result.photoDate!
                    ,photoLocLONG: result.photoLocLONG!
                    ,photoLocLAT: result.photoLocLAT!))
                
            }
            
        } catch { print(error) }

    }
    
    
    
   

    
}

