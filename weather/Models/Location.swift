//
//  Location.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import Foundation

struct Location: Codable {
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    var state: String
}
