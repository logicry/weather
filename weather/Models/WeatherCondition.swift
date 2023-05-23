//
//  WeatherCondition.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import Foundation

// This model is in its own file as it could be reused for forecasts in the future
struct WeatherCondition: Codable {
    let id: Int
    let icon: String
    let main: String
    let description: String
}
