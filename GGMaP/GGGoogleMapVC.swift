//
//  ViewController.swift
//  GGMaP
//
//  Created by Morshed Alam on 1/25/17.
//  Copyright © 2017 Morshed Alam. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class GGGoogleMapVC: UIViewController {
    var customMarkerBool = true
    @IBOutlet weak var tableView: UITableView!
    
    var locationNameAndAddress = [(name:String, address:String, destinationCoordinate :CLLocationCoordinate2D,location :CLLocation)]()
    
     let apiServerKey = "AIzaSyCyXL1cLs-MEJPg8vGtpWT1owvJYK45wu4"
    
    let marker : PlaceMarker! = nil
    let locationManager = CLLocationManager()
     var searchedTypes = [String]()
        let dataProvider = GoogleDataProvider()
    let searchRadius: Double = 1000
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchedTypes.append("resturant")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        
        
    }
    
    func fetchNearbyPlaces(_ coordinate: CLLocationCoordinate2D) {
        print(searchedTypes.count)
        if searchedTypes.count > 0{
        mapView.clear()
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            for place: GooglePlace in places {
                self.locationNameAndAddress.append((place.name, place.address, place.coordinate,place.location))
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView
                
            }
            
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.customMarkerBool = false
            let currentlocation = CLLocation(latitude: self.originCoordinate.latitude, longitude: self.originCoordinate.longitude)
            
            self.locationNameAndAddress.sort(by: {$0.location.distance(from: currentlocation) < $1.location.distance(from: currentlocation)})
            }
            self.tableView.reloadData()
    }
      
    }
    
   }


// MARK: - CLLocationManagerDelegate
extension GGGoogleMapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            locationManager.stopUpdatingLocation()
            originCoordinate = location.coordinate
            
            fetchNearbyPlaces(location.coordinate)
         
            
            let marker = GMSMarker()
            marker.position  = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            marker.appearAnimation = GMSMarkerAnimation.pop
            
            marker.icon = UIImage(named: "currentLocationIcon_icon")
            marker.map = mapView
            
        }
    }
   
    
    func currentLocationMarker(){
        let origin = CustomMarker(id: 0, name: "", address:"", duration: "", distance: "", imageName: "currentLocationIcon_icon", coordinate: self.originCoordinate)
        origin.map = self.mapView
    
    }
    
    
}




extension GGGoogleMapVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
       // reverseGeocodeCoordinate(position.target)
    }
    
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if customMarkerBool {
        let custommarker = marker as! CustomMarker
        if custommarker.id != 0  {
            if let infoView = UIView.viewFromNibName("MakerInfoView") as? MakerInfoView {
                infoView.duration.text = custommarker.duration
                infoView.distance.text = custommarker.distance
                return infoView
            }
            }}
        return nil
    }
    
    @IBAction func cancelOrRefresh(_ sender: UIBarButtonItem) {
        
        fetchNearbyPlaces(self.originCoordinate)
        currentLocationMarker()
    }
    
    @IBAction func addNewMode(_ sender: AnyObject) {
        
        let modecontroller = self.storyboard?.instantiateViewController(withIdentifier: "ModeTableViewController") as! ModeTableViewController
        if customMarkerBool {
            modecontroller.modeDelegate = self
        }
        self.navigationController?.pushViewController(modecontroller, animated: false)
        
        
        
    }
    
   
    
    
    }
    
extension GGGoogleMapVC:UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locationNameAndAddress.count
        
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = locationNameAndAddress[indexPath.row].name
        
        cell?.detailTextLabel?.text = locationNameAndAddress[indexPath.row].address

        return cell!
        
    }
    
   // https://maps.googleapis.com/maps/api/directions/json?units=metric&origin=37.785834,-122.406417&destination=37.7858718,-122.407731&mode=driving&waypoints=optimize:true|37.7858718,-122.407731&key=AIzaSyCyXL1cLs-MEJPg8vGtpWT1owvJYK45wu4
    
    
    func getDirections(_ origin: String!, destination: String!, waypoints: [String]!, travelMode: String,key:String){
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "units=metric" + "&origin=" + originLocation + "&destination=" + destinationLocation + "&mode=" + travelMode
                
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                directionsURLString += "&key=" + key
                
                directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                print(directionsURLString)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
        
                
                
                DispatchQueue.main.async(execute: { () -> Void in
                    Alamofire.request(directionsURLString).validate().responseJSON { response in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        switch response.result {
                        case .success(let data):
                            let json = JSON(data)
                            
                            if let status = json["status"].string{
                                if status == "OK"{
                                    if let route =  json["routes"][0].dictionary, let overlay = route["overview_polyline"]!.dictionary{
                                        self.makepath(overlay["points"]!.string!)
                                        // print( overlay["points"]!.string!)
                                        if let legs = route["legs"]![0].dictionary{
                                            let duration = legs["distance"]!["text"].stringValue
                                            let distance = legs["duration"]!["text"].stringValue
                                           // self.makeGmsmarker()
                                           // print(duration + "and" + distance)
                                            
        let origin = CustomMarker(id: 0, name: "", address: (legs["distance"]!.stringValue), duration: duration, distance: distance, imageName: "currentLocationIcon_icon", coordinate: self.originCoordinate)
           origin.map = self.mapView
                                            
       let destination = CustomMarker(id: 1, name: "", address: (legs["distance"]!.stringValue), duration: duration, distance: distance, imageName: "restaurant_pin", coordinate: self.destinationCoordinate)
            destination.map = self.mapView
//         let centerPoint = self.mapView.center
//         let coordinate = self.mapView.projection.coordinateForPoint(centerPoint)
//                                            
         self.mapView.camera = GMSCameraPosition(target: self.originCoordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                                        }
                                    }
                                }
                            }
                            
                        case .failure(let error):
                            print("Request failed with error: \(error)")
                        }
                    }
                    
                    
                })
                
            }}}
    
    
    
    func makepath(_ route:String){
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        let routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5
        routePolyline.strokeColor = UIColor.purple
        routePolyline.map = self.mapView
        
        
    }
    
    
    func makeGmsmarker(){
        
        
        let originMarker = GMSMarker(position: self.originCoordinate)
        originMarker.icon = UIImage(named: "currentLocationIcon_icon")
        originMarker.map = self.mapView
        
        let destinationMarker = GMSMarker(position: self.destinationCoordinate)
       destinationMarker.icon =  UIImage(named: "restaurant_pin")
        destinationMarker.map = self.mapView
        mapView.camera = GMSCameraPosition(target: self.originCoordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        
    }
    
    


    
    
    
//    
//    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((status: String, success: Bool) -> Void)?) {
//        if let originLocation = origin {
//            if let destinationLocation = destination {
//                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
//                if let routeWaypoints = waypoints {
//                    directionsURLString += "&waypoints=optimize:true"
//                    
//                    for waypoint in routeWaypoints {
//                        directionsURLString += "|" + waypoint
//                    }
//                }
//                print(directionsURLString)
//                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
//                
//                
//                 print(directionsURLString) 
//                let directionsURL = NSURL(string: directionsURLString)
//              
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    let directionsData = NSData(contentsOfURL: directionsURL!)
//                    do{
//                        let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
//                        
//                        let status = dictionary["status"] as! String
//                        
//                        if status == "OK" {
//                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
//                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
//                            
//                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
//                            
//                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
//                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
//                            
//                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
//                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
//                            
//                            let originAddress = legs[0]["start_address"] as! String
//                            let destinationAddress = legs[legs.count - 1]["end_address"] as! String
//                            
//                            let originMarker = GMSMarker(position: self.originCoordinate)
//                            originMarker.map = self.mapView
//                            originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
//                            originMarker.title = originAddress
//                            
//                            let destinationMarker = GMSMarker(position: self.destinationCoordinate)
//                            destinationMarker.map = self.mapView
//                            destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
//                            destinationMarker.title = destinationAddress
//                            
//                            if waypoints != nil && waypoints.count > 0 {
//                                for waypoint in waypoints {
//                                    let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
//                                    let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
//                                    
//                                    let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
//                                    marker.map = self.mapView
//                                    marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
//                                    
//                                }
//                            }
//                            
//                            let route = self.overviewPolyline["points"] as! String
//                            
//                            let path: GMSPath = GMSPath(fromEncodedPath: route)!
//                            let routePolyline = GMSPolyline(path: path)
//                            routePolyline.map = self.mapView
//                        }
//                        else {
//                            print("status")
//                            //completionHandler(status: status, success: false)
//                        }
//                    }
//                    catch {
//                        print("catch")
//                        
//                        // completionHandler(status: "", success: false)
//                    }
//                })
//            }
//            else {
//                print("Destination is nil.")
//                //completionHandler(status: "Destination is nil.", success: false)
//            }
//        }
//        else {
//            print("Origin is nil")
//            //completionHandler(status: "Origin is nil", success: false)
//        }
//    }
 
    
}
extension GGGoogleMapVC :UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapView.clear()
        destinationCoordinate = locationNameAndAddress[indexPath.row].destinationCoordinate
        let origin = "\(originCoordinate.latitude)"+"," + "\(originCoordinate.longitude)"
        let destination = "\(destinationCoordinate.latitude)"+"," + "\(destinationCoordinate.longitude)"
        customMarkerBool = true
        getDirections(origin, destination: destination, waypoints: [destination], travelMode:"walking", key: apiServerKey)
        
        
        
    }

}
extension GGGoogleMapVC:modeprotocol{
    
    func modeType(_ mode:String){
        mapView.clear()
        let origin = "\(originCoordinate.latitude)"+"," + "\(originCoordinate.longitude)"
        let destination = "\(destinationCoordinate.latitude)"+"," + "\(destinationCoordinate.longitude)"
        getDirections(origin, destination: destination, waypoints: [destination], travelMode:mode, key: apiServerKey)
        
        
    }
}



