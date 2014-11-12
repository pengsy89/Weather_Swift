//
//  ViewController.swift
//  Weather
//
//  Created by Siyuan Peng on 11/1/14.
//  Copyright (c) 2014 Siyuan Peng. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, ManagerDelegate {
    
    let locationManager : CLLocationManager = CLLocationManager()
    var currLocation : CLLocation!
    
    var lat: String="40.730023"
    var lon: String="-74.033457"
    let manager: Manager=Manager(mode: Mode.current)
    
    
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var placeL: UILabel!
    @IBOutlet weak var descL: UILabel!
    @IBOutlet weak var tempL: UILabel!
    @IBOutlet weak var tempMinL: UILabel!
    @IBOutlet weak var tempMaxL: UILabel!
    @IBOutlet weak var refreshB: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBAction func refreshAction(sender: AnyObject) {
        refreshB.hidden=true
        indicator.hidden=false
        indicator.startAnimating()
        
        manager.asyncFetchData(lat: lat, lon: lon)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyKilometer
        
        locationManager.startUpdatingLocation()
        
        manager.delegate=self
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        
        currLocation = locations.last as CLLocation
        
        self.lon="\(currLocation.coordinate.longitude)"
        self.lat="\(currLocation.coordinate.latitude)"
        
        locationManager.stopUpdatingLocation()
        
        refreshB.hidden=true
        indicator.hidden=false
        indicator.startAnimating()
        
        self.manager.asyncFetchData(lat: lat, lon: lon)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="goToGallery"{
            //            let index=picker.selectedRowInComponent(0)
            var vc=segue.destinationViewController as ForecastViewController
            vc.label.text="test"
            
        }
    }
    
    func success(){
        if let result=manager.current{
            tempL.text="\(result.temp)"
            tempMinL.text="\(result.tempMin)"
            tempMaxL.text="\(result.tempMax)"
            timeL.text="\(result.time!)"
            descL.text="\(result.desc!)"
            placeL.text="\(result.place!)"
            
            indicator.stopAnimating()
            indicator.hidden=true
            refreshB.hidden=false
        }
        
    }
    
    func fail(){
        self.tempL.text="oops!"
        self.descL.text="Check the network"
        
        indicator.stopAnimating()
        indicator.hidden=true
        refreshB.hidden=false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

