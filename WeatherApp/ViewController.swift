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
        switch segmented.selectedSegmentIndex
        {
        case 0:
            cell.tempLabel?.text = dict.temperature + " C"
        case 1:
            cell.tempLabel?.text = String(Double(dict.temperature)! + 273.15) + " K"
        case 2:
            cell.tempLabel?.text = String(Double(dict.temperature)! * 1.8 + 32) + " F"
        default:
            break
        }
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
    
    // First get values from API
    func getValues() {
        let manager = WeatherAPIManager.sharedInstance
        manager.requestGETURL(latitude: Double((self.myLocation?.latitude)!), longitude: Double((self.myLocation?.longitude)!), metric: "metric", success: { (json) in
            self.temp = manager.parserJSON(json: json)
            
            var ys1:[Int] = []
            var ys2:[Double] = []
            var valuesCel: [ChartDataEntry] = []
            
            for index in (0..<self.temp.count) {
                ys1.append(index)
                ys2.append(Double(self.temp[index].temperature)!)
                valuesCel.append(ChartDataEntry(x: Double(ys1[index]), y: Double(ys2[index])))
            }
            
            let data = LineChartData()
            let ds = LineChartDataSet(values: valuesCel, label: "Temperature")

            ds.colors = [NSUIColor.red]
            ds.drawCircleHoleEnabled = false
            ds.circleRadius = 1
            data.addDataSet(ds)

            self.lineChartView.data = data
            self.lineChartView.gridBackgroundColor = NSUIColor.white
            self.lineChartView.chartDescription?.text = "Weather"
            self.tblJSON.reloadData()
        } , failure: { (error) in
            print(error)})
    }

    
    //Just update value without API
    
    
    func update(value: String) {
        
        
        switch value
        {
        case "metric":
            
            var ys1:[Int] = []
            var ys2:[Double] = []
            var values: [ChartDataEntry] = []
            
            for index in (0..<self.temp.count) {
                ys1.append(index)
                ys2.append(Double(self.temp[index].temperature)!)
                values.append(ChartDataEntry(x: Double(ys1[index]), y: Double(ys2[index])))
            }
            let data = LineChartData()
            let ds = LineChartDataSet(values: values, label: "Temperature")
            
            ds.colors = [NSUIColor.red]
            ds.drawCircleHoleEnabled = false
            ds.circleRadius = 1
            data.addDataSet(ds)
            
            self.lineChartView.data = data
            self.lineChartView.gridBackgroundColor = NSUIColor.white
            self.lineChartView.chartDescription?.text = "Weather"
            self.tblJSON.reloadData()
        case "":
            var ys1:[Int] = []
            var ys2:[Double] = []
            var values: [ChartDataEntry] = []
            
            for index in (0..<self.temp.count) {
                ys1.append(index)
                ys2.append(Double(self.temp[index].temperature)!)
                values.append(ChartDataEntry(x: Double(ys1[index]), y: Double(ys2[index]) + 273.15))
            }
            let data = LineChartData()
            let ds = LineChartDataSet(values: values, label: "Temperature")
            
            ds.colors = [NSUIColor.red]
            ds.drawCircleHoleEnabled = false
            ds.circleRadius = 1
            data.addDataSet(ds)
            
            self.lineChartView.data = data
            self.lineChartView.gridBackgroundColor = NSUIColor.white
            self.lineChartView.chartDescription?.text = "Weather"
            self.tblJSON.reloadData()
            
        case "imperial":
            var ys1:[Int] = []
            var ys2:[Double] = []
            var values: [ChartDataEntry] = []
            
            for index in (0..<self.temp.count) {
                ys1.append(index)
                ys2.append(Double(self.temp[index].temperature)!)
                values.append(ChartDataEntry(x: Double(ys1[index]), y: Double(ys2[index])*2.4 + 32))
            }
            let data = LineChartData()
            let ds = LineChartDataSet(values: values, label: "Temperature")
            
            ds.colors = [NSUIColor.red]
            ds.drawCircleHoleEnabled = false
            ds.circleRadius = 1
            data.addDataSet(ds)
            
            self.lineChartView.data = data
            self.lineChartView.gridBackgroundColor = NSUIColor.white
            self.lineChartView.chartDescription?.text = "Weather"
            self.tblJSON.reloadData()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue = locations[locations.count-1]
        if locValue.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            
            self.myLocation = CLLocationCoordinate2D(latitude: locValue.coordinate.latitude, longitude: locValue.coordinate.longitude)
            
            getValues()
            
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

