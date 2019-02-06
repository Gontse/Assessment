//
//  ViewController.swift
//  DVT_WeatherApp
//
//  Created by Gontse Ranoto on 2019/02/01.
//  Copyright © 2019 Gontse Ranoto. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var _tableView: UITableView! {
        didSet{ _tableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var currTempLabel: UILabel!
    @IBOutlet weak var descrpLabel: UILabel! {
        didSet{descrpLabel.numberOfLines = 0}}
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var weatherBackgroundImage: UIImageView!
    @IBOutlet weak var currentWeatherView: UIView!
    
    
    var primaryColor = UIColor.clear
    var forecastData = [String: Weather]()
    var currentData = Weather(current: "--", max: "--", description: "" , min: "--", day: "")
    
    
    let _client = WeatherClient()
    let locationManager = CLLocationManager()
    var forecastCell = ForecastTableViewCell()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let currentDateString: String = dateFormatter.string(from: date)
        print("Current date is \(currentDateString)")
        
        //Authorize
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = 1.0
        }
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("current lat long : \(locations[0].coordinate)")
        
        _client.requestCurrentWeather(coordinates: locations[0].coordinate){ (weather) in
            print("Completion Handler: \(weather) " )
            
            self.currTempLabel.text = weather.current + "º"
            self.descrpLabel.text = weather.description
            
            self.minLabel.text = weather.min + "º"
            self.maxLabel.text = weather.max + "º"
            self.currentLabel.text = weather.current + "º"
            
            self.setWeatherTheme(description: weather.description);
            
            //Get Forecast
            self._client.requestWeatherForecast(coordinates: locations[0].coordinate){ (forecast) in
                self.forecastData = forecast
                self._tableView.reloadData()
            }
        }
        reverseGeoCode(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) { (placemark, error) in
            print((placemark?.country)! + " -> " + (placemark?.locality)! ) 
        }
    }
    
    
    func reverseGeoCode(latitude: Double, longitude: Double, complete: @escaping (CLPlacemark?, Error?)  -> ()){
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)){ placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                complete(nil, error)
                return
            }
            complete(placemark, nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ForecastTableViewCell.self), for: indexPath) as! ForecastTableViewCell
        
        cell.backgroundColor = primaryColor //UIColor(rgb: 0x54717A)
        let keys = Array(forecastData.keys);
        
        cell.dayofWeekLabel.text = forecastData[keys[indexPath.row]]?.day
        cell.dayTempLabel.text = (forecastData[keys[indexPath.row]]?.current)! + "º"
        cell.weatherIcon.image = UIImage(named: getForecastIconName((forecastData[keys[indexPath.row]]?.description)!))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastData.keys.count
    }
    
    //MARK:- Themes
    
    func getForecastIconName(_ desc: String) -> String {
        
        if(desc.contains("cloud")){
           return "partlysunny"
        }else if ( desc.contains("rain")){
           return "rain"
        }else{
            return "clear"
        }
    }
    
    
    func setWeatherTheme(description: String){
        if(description.contains("cloud")){
            cloudyTheme()
        }else if ( description.contains("rain")){
            rainnyTheme()
        }else{
            sunnyTheme()
        }
    }
    
    
    func rainnyTheme(){
        
        self.weatherBackgroundImage.image = UIImage(named:"forest_rainy")
        primaryColor = UIColor(rgb: 0x57575D)
        _tableView.backgroundColor = primaryColor
        currentWeatherView.backgroundColor = primaryColor
    }
    
    func sunnyTheme(){
        
        self.weatherBackgroundImage.image = UIImage(named: "forest_sunny" )
        primaryColor = UIColor(rgb: 0x47AB2F)
        currentWeatherView.backgroundColor = primaryColor
         _tableView.backgroundColor = primaryColor
    }
    
    func cloudyTheme() {
        
        self.weatherBackgroundImage.image = UIImage(named: "forest_cloudy")
        primaryColor = UIColor(rgb: 0x54717A)
        currentWeatherView.backgroundColor = primaryColor
         _tableView.backgroundColor = primaryColor
    }
}








