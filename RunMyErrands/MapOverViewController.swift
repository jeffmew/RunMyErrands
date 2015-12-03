//
//  ViewController.swift
//  RunMyErrands2Maps
//
//  Created by Steele on 2015-11-30.
//  Copyright © 2015 Steele. All rights reserved.
//

import UIKit
import GoogleMaps


enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}


class MapOverViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    
    //Mark: Properties
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var directionsLabel: UILabel!
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<CLLocationCoordinate2D> = []
    var waypointsArrayString: Array<String> = []
    
    var origin: CLLocationCoordinate2D!
    var destination: CLLocationCoordinate2D!
    
    var directionTask = DirectionManager()
    var locationManager: GeoManager!
    
    var travelMode = TravelModes.driving
    
    var routePolyline: GMSPolyline!
    
    var originMarker: GMSMarker!
    
    var didFindMyLocation = false
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.locationManager = GeoManager.sharedManager()
        self.locationManager.startLocationManager()
        
        self.mapView.delegate = self
        self.mapView.myLocationEnabled = true
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        
        //        //////test code/////
        //        let posn01 = CLLocationCoordinate2DMake(42.955420, -81.623233)
        //        let posn02 = CLLocationCoordinate2DMake(42.986950, -81.243177)
        //        let posn03 = CLLocationCoordinate2DMake(42.996950, -81.253177)
        //        let posn04 = CLLocationCoordinate2DMake(42.976950, -81.263177)
        //
        //        origin = CLLocationCoordinate2DMake(43.653226, -79.383184)
        //        destination = CLLocationCoordinate2DMake(42.314937, -83.036363)
        //
        //        let posn11 = "strathroy"
        //        let posn12 = "London, ontario"
        //
        //        waypointsArrayString += [posn11, posn12]
        //        waypointsArray += [posn01, posn02, posn03, posn04]
        //
        //        /////////////////////////////
        
        
        self.createRoute()
        self.mapView.addSubview(directionsLabel)
        self.mapView.bringSubviewToFront(directionsLabel)
        
    }
    
    //Update map with users current location;
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 12.0)
            mapView.settings.myLocationButton = true
            
            origin = myLocation.coordinate
            didFindMyLocation = true
        }
    }
    
    
    
    func configureMapAndMarkersForRoute() {
        // self.mapView.camera = GMSCameraPosition.cameraWithTarget(self.directionTask.originCoordinate, zoom: 9.0)
        
        originMarker = GMSMarker(position: self.directionTask.originCoordinate)
        originMarker.map = self.mapView
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.directionTask.originAddress
        originMarker.snippet = "Location"
        //originMarker.infoWindowAnchor = CGPointMake(0.5, 0.5)
        
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                
                let marker = GMSMarker(position: waypoint)
                marker.map = mapView
                marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
                
                markersArray.append(marker)
            }
        }
    }
    
    
    func createRoute() {
        
        self.directionTask.requestDirections(origin, taskWaypoints: waypointsArray, travelMode: self.travelMode, completionHandler: { (success) -> Void in
            if success {
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
                self.displayRouteInfo()
            }
        })
    }
    
    
    func drawRoute() {
        let route = directionTask.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5.0
        routePolyline.map = mapView
    }
    
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        waypointsArray.append(coordinate)
        
        task.setCoordinate(coordinate)
        
        
        if let polyline = routePolyline {
            self.recreateRoute()
        }else {
            self.createRoute()
        }
    }
    
    
    func clearRoute() {
        originMarker.map = nil
        routePolyline.map = nil
        originMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
    }
    
    
    func recreateRoute() {
        if let polyline = routePolyline {
            clearRoute()
            
            self.directionTask.requestDirections(origin, taskWaypoints: waypointsArray, travelMode: self.travelMode, completionHandler: { (success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
            })
        }
    }
    
    func displayRouteInfo() {
        directionsLabel.text = directionTask.totalDistance + "\n" + directionTask.totalTravelDuration + "\n" + directionTask.totalDuration
    }
    
    
    //Mark: MarkerInfoWindow
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let infoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil).first! as! CustomInfoWindow
        
        marker.infoWindowAnchor = CGPointMake(0, -0.05)
        infoWindow.title.text = marker.title
        infoWindow.snippit.text = marker.snippet
        
        //infoWindow.icon = UIImage
        
        
        return infoWindow
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        print("marker \(marker)")
    }
    
    
    
    
}

