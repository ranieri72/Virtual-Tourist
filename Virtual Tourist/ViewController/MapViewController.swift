//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 09/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    let viewControllerID = "photoVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(MKMapView.addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)
    }
    
    @objc private func addAnnotation(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        let location = sender.location(in: mapView)
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        let myPin: MKPointAnnotation = MKPointAnnotation()
        
        myPin.coordinate = myCoordinate
        mapView.addAnnotation(myPin)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let lat = view.annotation?.coordinate.latitude.description
        let long = view.annotation?.coordinate.longitude.description
        
        func sucess(photos: [Photo]) {
            performSegue(withIdentifier: viewControllerID, sender: photos)
        }
        func fail(msg: String) {
            presentAlertView(msg: msg)
        }
        Requester().getImagesFlickr(lat ?? "0.0", long ?? "0.0", sucess: sucess, fail: fail)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewControllerID {
            let view = segue.destination as! PhotoViewController
            let photos = sender as! [Photo]
            view.photos = photos
        }
    }
}
