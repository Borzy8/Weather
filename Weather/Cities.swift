//
//  Cities.swift
//  Weather
//
//  Created by Borzy on 21.09.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import Foundation

class City {
    var name = "";
    var forecastResults = [Forecast]();
    
    init(name: String, forecastResults: [Forecast]) {
        self.name = name;
        self.forecastResults = forecastResults;
    }
}
