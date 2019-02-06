//
//  WeatherClient.swift
//  DVT_WeatherApp
//
//  Created by Gontse Ranoto on 2019/02/03.
//  Copyright © 2019 Gontse Ranoto. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

class WeatherClient {

    var forecastDict = [String: Weather]()
    
    //CONSTANTS!
    let APPID = "724609282aebf937ea664af46f37e53a"
    let kelvin = 273
    // Resource URLs:
    let basePath = "http://api.openweathermap.org/data/2.5/"
    let currentWeather = "weather"
    let Forecast = "forecast"
    
  func requestCurrentWeather(coordinates: CLLocationCoordinate2D, completion: @escaping (Weather)  -> ()) {

  let parameter: Parameters = ["lat":coordinates.latitude , "lon" : coordinates.longitude ,"appid":APPID]
   let searchUrl = basePath + currentWeather

    Alamofire.request(searchUrl, method: .get, parameters: parameter).responseJSON { response in
        
        
        print("Request: \(String(describing: response.request))")   // original url request
             print("Response: \(String(describing: response.response))") // http url response
             print("Result: \(response.result)")                         // response serialization result
            if let json = response.result.value {
             let resp = JSON(json)

                let descrp = resp["weather"][0]["description"].stringValue
                let currentTemp = String(resp["main"]["temp"].intValue - self.kelvin)
                
                let minTemp = String(resp["main"]["temp_min"].intValue - self.kelvin)
                let maxTemp = String(resp["main"]["temp_max"].intValue - self.kelvin)
                
                let wther = Weather(current: currentTemp, max: maxTemp, description: descrp, min: minTemp,day: "")
               completion(wther)
                
                }
              // serialized json response
                //let swiftResp = JSON(json)
            }
        }
    
    func requestWeatherForecast(coordinates: CLLocationCoordinate2D, completion: @escaping ([String: Weather])  -> ()){
        
        
        
        
        let parameter: Parameters = ["lat":coordinates.latitude , "lon" : coordinates.longitude ,"appid":APPID]
        let searchUrl = basePath + Forecast
        
        Alamofire.request(searchUrl, method: .get, parameters: parameter).responseJSON { response in
            
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            if let json = response.result.value {
                self.forecastDict.removeAll()
                let resp = JSON(json)
          
                resp["list"].forEach({(x) in
                    
                  let dateStr =  x.1["dt_txt"].stringValue.components(separatedBy: " ")[0]
                    
                    if((self.forecastDict[dateStr]) == nil){
                        
                        self.forecastDict[dateStr] = Weather(current: String( x.1["main"]["temp"].intValue - self.kelvin) , max: String(x.1["main"]["temp_max"].intValue - self.kelvin), description:  x.1["weather"][0]["description"].stringValue, min:  String(x.1["main"]["temp_min"].intValue - self.kelvin ), day: self.getDayOfWeek(dateStr))
                    }
                })
              //  let sortedKeys = Array(self.forecastDict.keys).sorted()
               completion(self.forecastDict)
            }
            // serialized json response
            //let swiftResp = JSON(json)
        }
    }
    
    func getDayOfWeek(_ dateString: String) -> String {
        
        let dateFormatter = DateFormatter()
        let dateFormat = "yyyy-MM-dd"
        
        dateFormatter.dateFormat = dateFormat
        let startDate = dateFormatter.date(from: dateString)
        print("Current date is \(String(describing: startDate))")
        
        
        let dateFormatter2 = DateFormatter()
        // dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateFormatter2.dateFormat = "EEEE, MMMM dd, yyyy"
        let currentDateString: String = dateFormatter2.string(from: startDate!)

        let dayOfWeek = currentDateString.components(separatedBy: ",")[0]
        
        return dayOfWeek
        
        
    }

}




