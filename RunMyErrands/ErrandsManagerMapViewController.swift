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


class ErrandsManagerMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    
    //Mark: Properties
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var directionsLabel: UILabel!
    
    @IBOutlet weak var errandsTableView: UITableView!
    
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
    var taskArray:[Task] = []
    
    var orderedMarkerArray: [GMSMarker] = []
    var markerArray: [GMSMarker] = []
    
    var errandsManager: ErrandManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = mapView.bounds
        
        self.errandsManager = ErrandManager()
        
        self.locationManager = GeoManager.sharedManager()
        self.locationManager.startLocationManager()
        
        self.mapView.delegate = self
        self.mapView.myLocationEnabled = true
        self.errandsTableView.delegate = self
        self.errandsTableView.dataSource = self
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        
//        ////Test Data/////////////////////////////////
//        taskArray = [Task]()
//        
//        let task01:Task = Task.object()
//        task01.title = "Get Crack"
//        task01.subtitle = "become a crack head."
//        task01.category = 1
//        task01.setCoordinate(CLLocationCoordinate2DMake(49.2897225491339, -123.129493072629))
//        
//        let task02:Task = Task.object()
//        task02.title = "Get Weed"
//        task02.subtitle = "become a pot head."
//        task02.category = 2
//        task02.setCoordinate(CLLocationCoordinate2DMake(49.2835425227606, -123.130713142455))
//        
//        let task03:Task = Task.object()
//        task03.title = "Get Booze"
//        task03.subtitle = "become a  drunk."
//        task03.category = 3
//        task03.setCoordinate(CLLocationCoordinate2DMake(49.285996124658, -123.126992583275))
//        
//        let task04:Task = Task.object()
//        task04.title = "Get Smokes"
//        task04.subtitle = "become a smoker."
//        task04.category = 4
//        task04.setCoordinate(CLLocationCoordinate2DMake(49.2833437185792, -123.122600801289))
//        
//        let task05:Task = Task.object()
//        task05.title = "Get LSD"
//        task05.subtitle = "become a hippy."
//        task05.category = 5
//        task05.setCoordinate(CLLocationCoordinate2DMake(49.2777464723823, -123.131323009729))
//        
//        taskArray = [task01, task02, task03, task04, task05]
//        
//        ///////////////////////////////////////////////////////
        
        self.mapView.addSubview(directionsLabel)
        self.mapView.bringSubviewToFront(directionsLabel)
        
        navigationController?.navigationBarHidden = true
        
        directionsLabel.hidden = true
        
        
    }
    
    //Update map with users current location;
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 14.0)
            mapView.settings.myLocationButton = true
            mapView.animateToViewingAngle(45)
            origin = myLocation.coordinate
            didFindMyLocation = true
            //createRoute()
            self.populateTaskArray()
            
        }
    }
    
    
    func configureMapAndMarkersForRoute() {
        //self.mapView.camera = GMSCameraPosition.cameraWithTarget(self.directionTask.originCoordinate, zoom: 14.0)
        
        originMarker = GMSMarker(position: self.directionTask.originCoordinate)
        originMarker.map = self.mapView
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.directionTask.originAddress
        originMarker.snippet = "Location"
        
        if taskArray.count > 0 {
            for task in taskArray {
                
                let marker = task.makeMarker()
                marker.userData = task
                marker.map = mapView
                marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
                markerArray += [marker]
            }
        }
    }
    
    
    func createRoute() {
        
        self.directionTask.requestDirections(origin, taskWaypoints: taskArray, travelMode: self.travelMode, completionHandler: { (success) -> Void in
            if success {
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
                self.displayRouteInfo()
                
                if let polyline = self.routePolyline {
                    self.recreateRoute()
                }else {
                    self.createRoute()
                }
                self.orderedMarkerArray = self.reorderWaypoints()
                self.errandsTableView.reloadData()
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
    
    
//    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//        if let task = task {
//            task.setCoordinate(coordinate)
//        }
//        
//        if let polyline = self.routePolyline {
//            self.recreateRoute()
//        }else {
//            self.createRoute()
//        }
//    }
    
    
    func clearRoute() {
        originMarker.map = nil
        routePolyline.map = nil
        originMarker = nil
        routePolyline = nil
    }
    
    
    func recreateRoute() {
        //        if let polyline = routePolyline {
        //            clearRoute()
        //
        //            self.directionTask.requestDirections(origin, taskWaypoints: taskArray, travelMode: self.travelMode, completionHandler: { (success) -> Void in
        //                if success {
        //                    self.configureMapAndMarkersForRoute()
        //                    self.drawRoute()
        //                    self.displayRouteInfo()
        //                }
        //            })
        //        }
    }
    
    
    func displayRouteInfo() {
        directionsLabel.hidden = false
        directionsLabel.text = directionTask.totalDistance + "\n" + directionTask.totalTravelDuration + "\n" + directionTask.totalDuration
    }
    
    
    //Mark: MarkerInfoWindow
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let infoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil).first! as! CustomInfoWindow
        
        marker.infoWindowAnchor = CGPointMake(4.2, 0.7)
        infoWindow.title.text = marker.title
        infoWindow.snippit.text = marker.snippet
        
        if marker.userData != nil {
            
            let task:Task = marker.userData as! Task
            let imageName:String = task.imageName(task.category.intValue)
            infoWindow.icon.image = UIImage(named:imageName)
            
            for eachMarker in orderedMarkerArray {
                eachMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
            }
            
            marker.icon = GMSMarker.markerImageWithColor(UIColor.cyanColor())
    
        }

        //mapView.animateWithCameraUpdate(GMSCameraUpdate.setTarget(marker.position))
        
    
        // camera = GMSCameraPosition.cameraWithTarget(marker.position, zoom: 14.0)
       //mapView.camera = GMSCameraPosition.cameraWithLatitude(marker.position.latitude - 1.11, longitude: marker.position.longitude - 1.1, zoom: 14.0)
        
        
        return infoWindow
    }
    
    
    
    
    
    
    
    //Mark: - Navigation
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        
        performSegueWithIdentifier("GMapDetails", sender: marker.userData as! Task)
    }
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        if (segue.identifier == "GMapDetails") {
            let detailVC:DetailViewController = segue!.destinationViewController as! DetailViewController
            detailVC.task = sender as! Task
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedMarkerArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ErrandsManagerTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ErrandsManagerTableViewCell
        
        let task:Task = orderedMarkerArray[indexPath.row].userData as! Task
        print("Task \(task)")
        
        cell.titleLabel.text = task.title
        cell.subtitleLabel.text = task.subtitle
        
        let imageName = task.imageName(task.category.intValue)
        cell.categoryImage?.image = UIImage(named:imageName)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let marker = orderedMarkerArray[indexPath.row]
        
        for eachMarker in orderedMarkerArray {
            eachMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        }
        
        marker.icon = GMSMarker.markerImageWithColor(UIColor.cyanColor())
    }
    
    
    func reorderWaypoints() -> [GMSMarker] {
        
        var orderedMarkerArray:[GMSMarker] = [GMSMarker]()
        if let waypointOrder = directionTask.waypointOrder {
            for indexNumber in waypointOrder {
                orderedMarkerArray += [markerArray[indexNumber]]
            }
        }
        return orderedMarkerArray
    }
    
    
    func populateTaskArray() {
        
        errandsManager.fetchDataNew { (sucess) -> () in
            if sucess {
                
                let numberOfGroups = self.errandsManager.fetchNumberOfGroups()
                
                for var index in 0..<numberOfGroups {
                    
                    if let groupTaskArray = self.errandsManager.fetchErrandsForGroup(index) {
                        
                        for task in groupTaskArray {
                            self.taskArray += [task]
                        }
                    }
                }
            }
            self.createRoute()
        }
    }

    
    
    
    
}

