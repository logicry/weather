//
//  CurrentWeather.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import Foundation

// API Docs: https://openweathermap.org/current
// The reason for calling it CurrentWeather is the API's inconsistency when it comes to
// weather data in forecast calls - the model would have to be different there (as I briefly considered implementing forecasts too)
struct CurrentWeather: Codable {
    struct Info: Codable {
        enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case feelTemperature = "feels_like"
            case minTemperature = "temp_min"
            case maxTemperature = "temp_max"
            case humidity
        }
        
        let temperature: Double
        let feelTemperature: Double
        let minTemperature: Double
        let maxTemperature: Double
        let humidity: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case conditions = "weather"
        case info = "main"
    }
    
    let conditions: [WeatherCondition]
    
    // I'd prefer to move this sub-structure to the root of the model,
    // but I think it's fine for the purpose of this assignment
    let info: Info
}
