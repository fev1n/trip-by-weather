//
//  WeatherData.swift
//  TripByWeather
//
//  Created by Fevin Patel on 2023-12-07.
//

import Foundation

struct WeatherInfo : Decodable {
    let main : Main
    let weather : [Weather]
}
struct Main : Decodable{
    let temp : Double
    let temp_max : Double
    let temp_min : Double
    
}
struct Weather : Decodable{
    let icon: String
    let main: String
    let description : String
}
