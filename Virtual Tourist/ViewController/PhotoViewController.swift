//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 09/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit
import MapKit

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var btnNewCollection: UIButton!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    let cellIdentifier = "PhotoCollectionViewCell"
    
    var photos: [Photo]!
    private var lat: String!
    private var long: String!
    private var page: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        lat = photos[0].lat
        long = photos[0].long
        configMap(lat, long)
    }
    
    func configMap(_ lat: String, _ long: String) {
        let coordinate = CLLocationCoordinate2D(latitude: Double(lat) ?? 0.0, longitude: Double(long) ?? 0.0)
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
        func sucess(photos: [Photo]) {
            btnNewCollection.isEnabled = true
            page += 1
            self.photos = photos
            photoCollectionView.reloadData()
        }
        func fail(msg: String) {
            btnNewCollection.isEnabled = true
            presentAlertView(msg: msg)
        }
        Requester().getImagesFlickr(lat ?? "0.0", long ?? "0.0", page, sucess: sucess, fail: fail)
    }
    
    @IBAction func cancelPhotos(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePhotos(_ sender: UIBarButtonItem) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.setupCell(photo: photo)
        return cell
    }
}
