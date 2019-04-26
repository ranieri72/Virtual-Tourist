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
    }
    
    func addAnnotation(_ coordinate: CLLocationCoordinate2D) {
        let myPin: MKPointAnnotation = MKPointAnnotation()
        
        myPin.coordinate = coordinate
        mapView.addAnnotation(myPin)
    }
    
    @IBAction func newCollection(_ sender: UIButton) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        return cell
    }
}
