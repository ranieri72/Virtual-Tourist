//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 09/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    var dataController: DataController!
    let viewControllerID = "photoVC"
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lat", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath: nil,
            cacheName: "pins")
        do {
            try fetchedResultsController.performFetch()
            fetchPin()
        } catch {
            presentAlertView(msg: "Erro ao buscar os pinos!")
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        fetchedResultsController = nil
        
        let alt = mapView.camera.altitude
        let lat = mapView.centerCoordinate.latitude
        let long = mapView.centerCoordinate.longitude
        UserDefaults.standard.set(alt, forKey: "alt")
        UserDefaults.standard.set(lat, forKey: "lat")
        UserDefaults.standard.set(long, forKey: "long")
    }
    
    func fetchPin() {
        for pin in (fetchedResultsController?.fetchedObjects) ?? [Pin]() {
            let coord = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
            addAnnotation(geo: coord)
        }
    }
    
    @objc func addAnnotation(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        let location = sender.location(in: mapView)
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        addAnnotation(geo: myCoordinate)
        savePin(geo: myCoordinate)
    }
    
    func addAnnotation(geo: CLLocationCoordinate2D) {
        let myPin: MKPointAnnotation = MKPointAnnotation()
        myPin.coordinate = geo
        mapView.addAnnotation(myPin)
    }
    
    func savePin(geo: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.lat = geo.latitude
        pin.long = geo.longitude
//        do {
            dataController.viewContext.insert(pin)
//            try dataController.viewContext.save()
//        } catch {
//            presentAlertView(msg: "Pino não salvo!")
//        }
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            presentAlertView(msg: "Erro ao buscar os pinos!")
//        }
    }
    
    func configMap() {
        let uiLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MKMapView.addAnnotation(_:)))
        uiLongPressGestureRecognizer.minimumPressDuration = 1.0
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.addGestureRecognizer(uiLongPressGestureRecognizer)
        
        var alt = UserDefaults.standard.double(forKey: "alt")
        var lat = UserDefaults.standard.double(forKey: "lat")
        var long = UserDefaults.standard.double(forKey: "long")
        alt = alt == 0.0 ? 14000000.0 : alt
        lat = lat == 0.0 ? -12.072204 : lat
        long = long == 0.0 ? -47.002209 : long
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let mapCamera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: alt)
        mapView.setCamera(mapCamera, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let lat = view.annotation?.coordinate.latitude
        let long = view.annotation?.coordinate.longitude
        
        if let pins = (fetchedResultsController?.fetchedObjects?.filter { $0.lat == lat && $0.long == long }) {
            if !pins.isEmpty {
                let pin = pins[0]
                if (pin.photos?.allObjects.isEmpty)! {
                    getImagesFlickr(pins[0])
                } else {
                    performSegue(withIdentifier: viewControllerID, sender: pin)
                }
            } else {
                presentAlertView(msg: "Pino não salvo!")
            }
        }
    }
    
    func getImagesFlickr( _ pin: Pin) {
        func sucess() {
            performSegue(withIdentifier: viewControllerID, sender: pin)
        }
        func fail(msg: String) {
            presentAlertView(msg: msg)
        }
        Requester(context: dataController.viewContext).getImagesFlickr(pin: pin, page: 1, sucess: sucess, fail: fail)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewControllerID {
            let view = segue.destination as! PhotoViewController
            let pin = sender as! Pin
            view.pin = pin
            view.dataController = dataController
        }
    }
}
