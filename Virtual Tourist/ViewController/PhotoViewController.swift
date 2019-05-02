//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 09/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var btnNewCollection: UIButton!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    private let cellIdentifier = "PhotoCollectionViewCell"
    
    var dataController: DataController!
    private var saveObserverToken: Any?
    private var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var pin: Pin!
    private var page: Int = 2
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "lat", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addSaveNotificationObserver()
        initView()
        configMap()
    }
    
    //    deinit {
    //        removeSaveNotificationObserver()
    //    }
    
    func initView() {
        let space:CGFloat = 3.0
        let dimensionW = (view.frame.size.width - (2 * space)) / 3.0
        let dimensionH = (view.frame.size.height - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimensionW, height: dimensionH)
        
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
    }
    
    func configMap() {
        let lat = pin.lat
        let long = pin.long
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let mapCamera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 500.0)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.isUserInteractionEnabled = false
        mapView.mapType = MKMapType.standard
        mapView.addAnnotation(annotation)
        mapView.setCamera(mapCamera, animated: false)
    }
    
    @IBAction func newCollection(_ sender: UIButton) {
        btnNewCollection.isEnabled = false
        func sucess() {
            btnNewCollection.isEnabled = true
            page += 1
            
            
            // FIXME:
            photoCollectionView.reloadData()
        }
        func fail(msg: String) {
            btnNewCollection.isEnabled = true
            presentAlertView(msg: msg)
        }
        Requester().getImagesFlickr(context: dataController.viewContext, pin: pin, page: page, sucess: sucess, fail: fail)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func savePhoto( _ photo: Photo) {
        let backgroundContext: NSManagedObjectContext! = dataController?.backgroundContext
        
        let photoID = photo.objectID
        
        dataController?.backgroundContext.perform {
            let backgroundPhoto = backgroundContext.object(with: photoID) as! Photo
            backgroundPhoto.image = photo.image
            try? backgroundContext.save()
        }
    }
    
    func downloadImages(photo: Photo) {
        func sucess(image: UIImage?) {
            photo.image = image
            savePhoto(photo)
        }
        func fail(msg: String) {
            
        }
        Requester().downloadImages(urlString: photo.url!, sucess: sucess, fail: fail)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let photo = photos[indexPath.row]
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        // FIXME:
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.setupCell(photo: photo)
        return cell
    }
}

//extension PhotoViewController {
//
//    func addSaveNotificationObserver() {
//        removeSaveNotificationObserver()
//        saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: dataController?.viewContext, queue: nil, using: handleSaveNotification(notification:))
//    }
//
//    func removeSaveNotificationObserver() {
//        if let token = saveObserverToken {
//            NotificationCenter.default.removeObserver(token)
//        }
//    }
//}

extension PhotoViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photoCollectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            photoCollectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            photoCollectionView.reloadItems(at: [indexPath!])
        case .move:
            photoCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
}
