//
//  WeatherProvider.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import UIKit

protocol WeatherProviderContract {
    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> CurrentWeather
    func getWeatherConditionIcon(name: String) async throws -> UIImage?
}

class WeatherProvider: WeatherProviderContract {
    private static let host = "https://api.openweathermap.org/data/2.5"
    
    private let webProvider: WebProviderContract
    
    init(webProvider: WebProviderContract = WebProvider.shared) {
        self.webProvider = webProvider
    }
    
    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> CurrentWeather {
        var url = URL(string: "\(Self.host)/weather")!
        url.append(queryItems: [
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "appid", value: WebProvider.weatherApiKey),
            URLQueryItem(name: "units", value: "imperial") // Since we're just querying for US cities
        ])
        
        do {
            let (data, _) = try await self.webProvider.get(from: url)
            return try JSONDecoder().decode(CurrentWeather.self, from: data)
        } catch {
            debugPrint("\(#function) failed with \(error)")
            throw WebProviderError.responseFailure
        }
    }
    
    func getWeatherConditionIcon(name: String) async throws -> UIImage? {
        let url = URL(string: "https://openweathermap.org/img/wn/\(name)@2x.png")!
        let request = URLRequest(url: url)
        
        // We could dig deeper in terms of cache expiration
        if let cached = URLCache.shared.cachedResponse(for: request) {
            return UIImage(data: cached.data, scale: 2)
        }
        
        do {
            let (data, response) = try await self.webProvider.get(from: url)
            URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            return UIImage(data: data, scale: 2)
        } catch {
            debugPrint("\(#function) failed with \(error)")
            throw WebProviderError.responseFailure
        }
    }
}
