//
//  Weather.swift
//  DVT_WeatherApp
//
//  Created by Gontse Ranoto on 2019/02/02.
//  Copyright © 2019 Gontse Ranoto. All rights reserved.
//

import Foundation

struct Weather {
    
    let current: String
    let max: String
    let min : String
    let description: String
    let day: String
    
    init(current:String, max:String, description:String,  min:String , day: String) {
        
        self.current = current
        self.max = max
        self.description = description
        self.min = min
        self.day = day
        
    }
    

    
   }


