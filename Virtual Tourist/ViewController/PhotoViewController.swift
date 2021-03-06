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

class PhotoViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var btnNewCollection: UIButton!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    private let cellIdentifier = "PhotoCollectionViewCell"
    
    private var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var pin: Pin!
    private var page: Int = 2
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        configMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
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
    
    // MARK: CoreData
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DataController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func saveViewContext() {
        try? DataController.shared.viewContext.save()
    }
    
    func deletePhotos() {
        let photos = fetchedResultsController.fetchedObjects
        for item in photos! {
            DataController.shared.viewContext.delete(item)
            saveViewContext()
        }   
        self.requestImages()
    }
    
    func deletePhoto(_ photo: NSManagedObject) {
        DataController.shared.viewContext.delete(photo)
        saveViewContext()
    }
    
    // MARK: Button
    
    @IBAction func newCollection(_ sender: UIButton) {
        deletePhotos()
        btnNewCollection.isEnabled = false
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Request
    
    func requestImages() {
        func sucess() {
            btnNewCollection.isEnabled = true
            page += 1
        }
        func fail(msg: String) {
            btnNewCollection.isEnabled = true
            presentAlertView(msg: msg)
        }
        Requester().getImagesFlickr(pin: pin, page: page, sucess: sucess, fail: fail)
    }
}

// MARK: CollectionView

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.setupCell(photo: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        deletePhoto(photo)
    }
}

// MARK: Fetch
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
