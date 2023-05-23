//
//  GeocodingProvider.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import Foundation

protocol GeocodingProviderContract {
    func getLocation(of city: String) async throws -> Location?
    func getCity(latitude: Double, longitude: Double) async throws -> Location?
}

class GeocodingProvider: GeocodingProviderContract {
    private static let host = "https://api.openweathermap.org/geo/1.0"
    
    private let webProvider: WebProviderContract
    
    init(webProvider: WebProviderContract = WebProvider.shared) {
        self.webProvider = webProvider
    }
    
    func getLocation(of city: String) async throws -> Location? {
        var url = URL(string: "\(Self.host)/direct")!
        url.append(queryItems: [
            URLQueryItem(name: "q", value: "\(city),,USA"),
            URLQueryItem(name: "appid", value: WebProvider.weatherApiKey),
            URLQueryItem(name: "limit", value: "1")
        ])
        
        do {
            let (data, _) = try await self.webProvider.get(from: url)
            let locations = try JSONDecoder().decode([Location].self, from: data)
            return locations.first
        } catch {
            debugPrint("\(#function) failed with \(error)")
            throw WebProviderError.responseFailure
        }
    }
    
    func getCity(latitude: Double, longitude: Double) async throws -> Location? {
        var url = URL(string: "\(Self.host)/reverse")!
        url.append(queryItems: [
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "appid", value: WebProvider.weatherApiKey),
            URLQueryItem(name: "limit", value: "1")
        ])
        
        do {
            let (data, _) = try await self.webProvider.get(from: url)
            let locations = try JSONDecoder().decode([Location].self, from: data)
            return locations.first
        } catch {
            debugPrint("\(#function) failed with \(error)")
            throw WebProviderError.responseFailure
        }
    }
}
