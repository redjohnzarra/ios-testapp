//
//  MapVC.swift
//  ios-testapp
//
//  Created by Reden John Zarra on 06/12/2018.
//  Copyright © 2018 Reden John Zarra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000 //1000 meters
    let directionRequest = MKDirections.Request()
    let screenSize = UIScreen.main.bounds
    
    var selectedUserCoordinate: CLLocationCoordinate2D?
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var tableView: UITableView?
    var restaurantsArray = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
//        mapView.showsUserLocation = true
        locationManager.delegate = self
        
        configureLocationServices()
        addPinch()
        addDoubleTap()
        
        drawFromAndToRoute(from: "Narva, Estonia", to: "Tallinn, Estonia") //Draws the route from Narva, Estonia to Tallinn, Estonia when app has been loaded
    }
    
    func addPinch() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomMapView(sender:)))
        pinch.delegate = self
        
        mapView.addGestureRecognizer(pinch)
    }
    
    /// Adds a double tap gesture recognizer on the mapview
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2 //2 for double tap
        doubleTap.delegate = self
        
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipeUp() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(animateViewUp))
        swipeUp.direction = .up
        pullUpView.addGestureRecognizer(swipeUp)
    }
    
    func addSwipeDown() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipeDown.direction = .down
        pullUpView.addGestureRecognizer(swipeDown)
    }
    
    /// Animates Pull Up View Upwards
    @objc func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    /// Animates Pull Up View Downwards
    @objc func animateViewDown() {
        pullUpViewHeightConstraint.constant = 20
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    /// Adds spinner icon on pull-up view
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: pullUpView.frame.height / 2)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 100, y: (pullUpView.frame.height / 2) + 25, width: 200, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "Fetching restaurants"
        pullUpView.addSubview(progressLabel!)
    }
    
    func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    func addTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 20, width: pullUpView.frame.width, height: pullUpView.frame.height - 20))
        tableView?.register(RestaurantCell.self, forCellReuseIdentifier: "restaurantCell")
        tableView?.delegate = self
        tableView?.dataSource = self
        
        pullUpView.addSubview(tableView!)
    }
    
    func removeTableView() {
        if tableView != nil {
            tableView?.removeFromSuperview()
        }
    }
    
    @IBAction func centerMapBtnPressed(_ sender: Any) {
        if(authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse){
//            centerMapOnUserLocation()
            centerMapOnSelectedUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    /// Centers the map on the device's location
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        centerMapOnLocation(coordinate: coordinate)
    }
    
    func centerMapOnSelectedUserLocation() {
        if(selectedUserCoordinate != nil){
            centerMapOnLocation(coordinate: selectedUserCoordinate!)
        } else {
            print("No selected coordinate yet")
        }
    }
    
    /// Centers the map on the provided coordinate, zooms in based on the defined radius, and search nearby restaurants
    ///
    /// - Parameter coordinate: coordinate where map will be centered
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let locationRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0) // * 2.0 for a Thousand meters from left and right / up and down
        
        mapView.setRegion(locationRegion, animated: true)
    }
    
    /// Search the map based on the string provided (either restaurants, gas stations and etc). In this case it is restaurants
    ///
    /// - Parameters:
    ///   - naturalLanguageQuery: Query string to be search (ex. restaurant)
    ///   - region: the region where the query string will be searched
    func searchBy(naturalLanguageQuery: String, region: MKCoordinateRegion) {
        self.restaurantsArray = [Restaurant]()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = naturalLanguageQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error on searching \(naturalLanguageQuery)", error)
                return
            }
            var restaurants: [MKMapItem]? = nil
            if(response.mapItems.count > 9){
                restaurants = Array(response.mapItems[0..<9]) //to get first 9 restaurants only
            }else{
                restaurants = response.mapItems
            }
            
            if(restaurants != nil){
                for restaurant in restaurants! {
                    let placemark: MKPlacemark? = restaurant.placemark
                    var addressArray = [placemark?.thoroughfare, placemark?.subLocality, placemark?.administrativeArea, placemark?.postalCode, placemark?.country]
                    var address = addressArray.compactMap{$0}.joined(separator: ", ")
                    let annotation = RestaurantAnnotation(title: restaurant.name ?? "", subtitle: address, coordinate: placemark?.coordinate ?? CLLocationCoordinate2D(), identifier: "restaurantPin")
                    self.mapView.addAnnotation(annotation)
                    
                    var restaurantData = Restaurant(name: restaurant.name ?? "", address: address, phoneNumber: restaurant.phoneNumber ?? "", latitude: placemark?.coordinate.latitude ?? 0.0, longitude: placemark?.coordinate.longitude ?? 0.0)
                    
                    self.restaurantsArray.append(restaurantData)
                }
                
                self.addTableView()
            }
        }
    }
    
    
    /// Draw the route of two points the source and destination
    ///
    /// - Parameters:
    ///   - from: The source of the route in String
    ///   - to: The destination of the route in String
    func drawFromAndToRoute(from: String, to: String) {
        //Have used a callback to be sure that the first location has been set before proceeding to the next one. After the source and destination locations have been set successfully, then the route is calculated and then shown on the map
        setDirectionRequestLocations(address: from, type: "source", completion: {
            self.setDirectionRequestLocations(address: to, type: "destination", completion: {
                self.directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: self.directionRequest)
                directions.calculate { (response, error) in
                    if error != nil {
                        print("Error getting directions", error)
                    } else {
                        self.showRoute(response!)
                    }
                }
            })
        })
    }
    
    
    /// Drop a custom Pin on the map upon double clicking (objc to be used as a selector)
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removeTableView()
        removeSpinner()
        removeProgressLabel()
        
        removePinAnnotation(completion: {
            let touchPoint = sender.location(in: mapView) //Coordinates of screen (pts)
            selectedUserCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView) //map view coordinates
            
            let annotation = DroppablePin(coordinate: selectedUserCoordinate!, identifier: "droppablePin")
            mapView.addAnnotation(annotation)
            
            let locationRegion = MKCoordinateRegion(center: selectedUserCoordinate!, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0) // * 2.0 for a Thousand meters from left and right / up and down
            
            mapView.setRegion(locationRegion, animated: true)
            searchBy(naturalLanguageQuery: "restaurant", region: locationRegion)
           
            self.animateViewUp()
            self.addSwipeUp()
            self.addSwipeDown()
            self.addSpinner()
            addProgressLabel()
        }) //before dropping a pin annotation, remove existing annotations
    }
    
    
    /// Removed existing map annotations. This includes restaurants and the previously selected location
    func removePinAnnotation(completion: () -> Void) {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
        completion()
    }
    
    
    /// Converts the String address to Coordinates, then placemark, then mapItem to be used on MKDirection Request (considering that the parameter required is MKMapItem
    ///
    /// - Parameters:
    ///   - address: Address of the location to be converted (in String)
    ///   - type: Type of location (either source or destination)
    ///   - completion: Callback function after the string location has been converted and set successfully
    func setDirectionRequestLocations(address: String, type: String, completion: @escaping () -> Void) {
        let geocorder = CLGeocoder()
        geocorder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let firstPlaceMark = placemarks?.first,
                let location = firstPlaceMark.location?.coordinate
                else {
                    print("No coordinates found", error)
                    // handle no location found
                    return
            }
            
            let selectedPlacemark = MKPlacemark(coordinate: location)
            let selectedMapItem = MKMapItem(placemark: selectedPlacemark)

            if(type == "source"){
                self.directionRequest.source = selectedMapItem
            }else if(type == "destination"){
                self.directionRequest.destination = selectedMapItem
            }
            
            completion()
        }
    }
    
    /// Shows the route on the map and centers the phone's view on it
    ///
    /// - Parameter response: MKDirection response based on the source and destination coordinates given
    func showRoute(_ response: MKDirections.Response) {
        print("showRoute response here", response)
        for route in response.routes {
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            topLabel.text = "Double Tap to simulate user location"
//            for step in route.steps {
//                print(step.instructions)
//            }
        }
    }
    
    
    /// Specifies the properties for the route line to be drawn when it is displayed in the mapview
    ///
    /// - Parameters:
    ///   - mapView
    ///   - overlay
    /// - Returns: MKOverlayRenderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.01282052616, green: 0.1911768364, blue: 1, alpha: 0.7956095951)
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if(annotation is MKUserLocation) {
            return nil
        }
        
        if(selectedUserCoordinate != nil){
            if(annotation.coordinate.latitude == selectedUserCoordinate?.latitude && annotation.coordinate.longitude == selectedUserCoordinate?.longitude){
                return nil
            }
        }
        
        var restoAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "restaurantPin")
        restoAnnotation.canShowCallout = true
        let restoIcon = UIImage(named: "restoIcon")
        
        restoAnnotation.image = restoIcon
        
        return restoAnnotation
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedAnnotation = view.annotation as? RestaurantAnnotation
        let latitude = selectedAnnotation?.coordinate.latitude
        let longitude = selectedAnnotation?.coordinate.longitude
        for (index, restaurant) in restaurantsArray.enumerated() {
            if restaurant.latitude == latitude && restaurant.longitude == longitude {
                let indexPath = IndexPath(row: index, section: 0)
                tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            }
        }
    }
    
    @objc func zoomMapView(sender: UIPinchGestureRecognizer) {
        if sender.scale < 1.0 {
            //fingers closer (zoom out)
            mapView.setZoomByDelta(delta: 2, animated: true)
        } else if sender.scale > 1.0 {
            //fingers apart (zoom in)
            mapView.setZoomByDelta(delta: 0.5, animated: true)
        }
        
    }
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        centerMapOnUserLocation()
    }
}

extension MapVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRestaurant = restaurantsArray[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: selectedRestaurant.latitude, longitude: selectedRestaurant.longitude)
        centerMapOnLocation(coordinate: coordinate)
        for annotation in mapView.annotations {
            if(annotation.coordinate.latitude == selectedRestaurant.latitude && annotation.coordinate.longitude == selectedRestaurant.longitude){
                //Added delay to show the tooltip at center
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // change 0.3 to desired number of seconds
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantCell
        
        if(restaurantsArray.count > 0){
            let restaurant = restaurantsArray[indexPath.row]
            cell?.restoName.text = restaurant.name
            cell?.restoAddress.text = restaurant.address
            cell?.restoPhoneNumber.text = restaurant.phoneNumber
        }
        
        return cell!
    }
}

// Added zoom functionality on mapview
extension MKMapView {
    func setZoomByDelta(delta: Double, animated: Bool) {
        var _region = region;
        var _span = region.span;
        _span.latitudeDelta *= delta;
        _span.longitudeDelta *= delta;
        _region.span = _span;
        
        setRegion(_region, animated: animated)
    }
}
