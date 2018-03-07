//
//  ViewController.swift
//  WeatherApp
//
//  Created by Сергей on 05/03/2018.
//  Copyright © 2018 Sergei. All rights reserved.
//

import UIKit
import Charts
import MapKit
import Alamofire
import SwiftyJSON


class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    
    
    @IBOutlet weak var tblJSON: UITableView!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weather") as! WeatherTableViewCell
        let dict = data[indexPath.row]
        cell.tempLabel?.text = dict.temperature + " C"
        cell.dateLabel?.text = dict.dateTime
        return cell
    }
    
    @IBOutlet var lineChartView: LineChartView!
    var lineChartEntry = [ChartDataEntry]()
    
    var data:[Weather] = []
    
    var ys2:[Double] = []
    var ys1:[Int] = []
    
    var myLocation: CLLocation?

    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue = locations[locations.count-1]
        if locValue.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            
            let lat = locValue.coordinate.latitude
            let long = locValue.coordinate.longitude
            
            
            let manager = WeatherAPIManager.sharedInstance
            manager.requestGETURL(latitude: lat, longitude: long, metric: "metric", success: { (json) in
                for i in stride(from: 0, to: json["list"].count, by: 1) {
                    
                    
                    self.data.append(Weather(dateTime: json["list"][i]["dt_txt"].stringValue, temperature: json["list"][i]["main"]["temp"].stringValue))
                    self.ys1.append(i)
                    self.ys2.append(json["list"][i]["main"]["temp"].doubleValue)
                    
                }
                
                var values: [ChartDataEntry] = []
                
                for index in (0..<self.ys1.count) {
                    values.append(ChartDataEntry(x: Double(self.ys1[index]), y: Double(self.ys2[index])))
                }
                
                
                let data = LineChartData()
                
                let ds1 = LineChartDataSet(values: values, label: "Temperature")
                ds1.colors = [NSUIColor.red]
                data.addDataSet(ds1)
                
                self.lineChartView.data = data
                
                self.lineChartView.gridBackgroundColor = NSUIColor.white
                
                self.lineChartView.chartDescription?.text = "Weather"
                
                
                if self.data.count > 0 {
                    self.tblJSON.reloadData()
                }
                
                
                
            }, failure: { (error) in
                print(error)})
            
            
            
            
        }
        
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.requestAlwaysAuthorization()
        

        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        

        
        
        
        
        tblJSON.delegate = self
        tblJSON.dataSource = self
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


}

