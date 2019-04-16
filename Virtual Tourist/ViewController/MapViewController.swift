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
        performSegue(withIdentifier: viewControllerID, sender: view.annotation?.coordinate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewControllerID {
            let view = segue.destination as! PhotoViewController
            let location = sender as! CLLocationCoordinate2D
            view.location = location
        }
    }
}
