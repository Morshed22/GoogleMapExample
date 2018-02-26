//
//  GooglePlace.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GooglePlace {
  let name: String
  let address: String
  let coordinate: CLLocationCoordinate2D
  let placeType: String
  var photoReference: String?
  var photo: UIImage?
    var location :CLLocation
    
  
  init(dictionary:[String : AnyObject], acceptedTypes: [String])
  {
    let json = JSON(dictionary)
    name = json["name"].stringValue
    address = json["vicinity"].stringValue
    
    let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
    let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
    coordinate = CLLocationCoordinate2DMake(lat, lng)
    location = CLLocation(latitude: lat, longitude: lng)
    
    photoReference = json["photos"][0]["photo_reference"].string
    
    var foundType = "restaurant"
    let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    for type in json["types"].arrayObject as! [String] {
      if possibleTypes.contains(type) {
        foundType = type
        break
      }
    }
    
    print(foundType)
    
    placeType = foundType
  }
    
    
    
}
/*

 
 //https://maps.googleapis.com/maps/api/directions/json?units=metric&origin=37.785834,-122.406417&destination=37.7858718,-122.407731&mode=driving
 
func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((status: String, success: Bool) -> Void)?) {
    if let originLocation = origin {
        if let destinationLocation = destination {
            var directionsURLString = baseURLDirections + "units=metric&" + "origin=" + originLocation + "&destination=" + destinationLocation + ""
            if let routeWaypoints = waypoints {
                directionsURLString += "&waypoints=optimize:true"
                
                for waypoint in routeWaypoints {
                    directionsURLString += "|" + waypoint
                }
            }
            directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            print(directionsURLString)
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                Alamofire.request(.GET, directionsURLString).validate().responseJSON { response in
                    switch response.result {
                    case .Success(let data):
                        let json = JSON(data)
                        
                        if let status = json["status"].string{
                            if status == "OK"{
                                if let route =  json["routes"][0].dictionary, let overlay = route["overview_polyline"]!.dictionary{
                                    self.makepath(overlay["points"]!.string!)
                                    // print( overlay["points"]!.string!)
                                    if let legs = route["legs"]![0].dictionary{
                                        let duration = legs["distance"]!["text"].stringValue
                                        let distance = legs["duration"]!["text"].stringValue
                                        self.makeGmsmarker()
                                    }
                                }
                            }
                        }
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                    }
                }
                
                
            })
            
        }}}



func makepath(route:String){
    let path: GMSPath = GMSPath(fromEncodedPath: route)!
    let routePolyline = GMSPolyline(path: path)
    routePolyline.strokeWidth = 5
    routePolyline.strokeColor = UIColor.purpleColor()
    routePolyline.map = self.mapView
    
    
}


func makeGmsmarker(){
    let originMarker = GMSMarker(position: self.originCoordinate)
    originMarker.map = self.mapView
    originMarker.icon = UIImage(named: "currentLocationIcon_icon")
    
    let destinationMarker = GMSMarker(position: self.destinationCoordinate)
    destinationMarker.map = self.mapView
    destinationMarker.icon =  UIImage(named: "restaurant_pin")
    mapView.camera = GMSCameraPosition(target: self.originCoordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    
    
}

*/




