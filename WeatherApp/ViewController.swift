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
    
    @IBOutlet weak var segmented: UISegmentedControl!
    
    @IBAction func changeValue(_ sender: Any) {
        switch segmented.selectedSegmentIndex
        {
        case 0:
            self.update(value: "metric")
        case 1:
            self.update(value: "")
        case 2:
            self.update(value: "imperial")
        default:
            break
        }
    }
    
    
    @IBOutlet weak var tblJSON: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return temp.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weather") as! WeatherTableViewCell
        let dict = temp[indexPath.row]
        cell.tempLabel?.text = dict.temperature
        cell.dateLabel?.text = dict.dateTime
        return cell
    }
        
    
    @IBOutlet var lineChartView: LineChartView!
    var lineChartEntry = [ChartDataEntry]()
    
    var ys2:[Double] = []
    var ys1:[Int] = []
    
    var myLocation: CLLocationCoordinate2D?

    let locationManager = CLLocationManager()
    
    var temp:[Weather] = []
    
    func update(value: String) {
        let manager = WeatherAPIManager.sharedInstance
        manager.requestGETURL(latitude: Double((self.myLocation?.latitude)!), longitude: Double((self.myLocation?.longitude)!), metric: value, success: { (json) in
            
            self.temp = manager.parserJSON(json: json)
          
            for index in (0..<self.temp.count) {
                self.ys1.append(index)
                self.ys2.append(Double(self.temp[index].temperature)!)
            }
            
            var valuesCel: [ChartDataEntry] = []
            var valuesKel: [ChartDataEntry] = []
            var valuesFar: [ChartDataEntry] = []
            for index in (0..<self.temp.count) {
                valuesCel.append(ChartDataEntry(x: Double(self.ys1[index]), y: Double(self.ys2[index])))
                valuesKel.append(ChartDataEntry(x: Double(self.ys1[index]), y: Double(self.ys2[index]) + 273.15))
                valuesFar.append(ChartDataEntry(x: Double(self.ys1[index]), y: Double(self.ys2[index])*2.4 + 32))
            }
            
            switch value
            {
            case "metric":
                let data = LineChartData()
                let ds = LineChartDataSet(values: valuesCel, label: "Temperature")
                
                ds.colors = [NSUIColor.red]
                data.addDataSet(ds)
                
                self.lineChartView.data = data
                self.lineChartView.gridBackgroundColor = NSUIColor.white
                self.lineChartView.chartDescription?.text = "Weather"
            case "":
                let data = LineChartData()
                let ds = LineChartDataSet(values: valuesKel, label: "Temperature")
                
                ds.colors = [NSUIColor.red]
                data.addDataSet(ds)
                
                self.lineChartView.data = data
                self.lineChartView.gridBackgroundColor = NSUIColor.white
                self.lineChartView.chartDescription?.text = "Weather"
            case "imperial":
                let data = LineChartData()
                let ds = LineChartDataSet(values: valuesFar, label: "Temperature")
                
                ds.colors = [NSUIColor.red]
                data.addDataSet(ds)
                
                self.lineChartView.data = data
                self.lineChartView.gridBackgroundColor = NSUIColor.white
                self.lineChartView.chartDescription?.text = "Weather"
            default:
                break
            }
            
            
            
            
            

            self.tblJSON.reloadData()

        
        } , failure: { (error) in
            print(error)})

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue = locations[locations.count-1]
        if locValue.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            
            self.myLocation = CLLocationCoordinate2D(latitude: locValue.coordinate.latitude, longitude: locValue.coordinate.longitude)
            
            update(value: "metric")
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

