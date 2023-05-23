//
//  WeatherViewModel.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import UIKit
import CoreLocation

@MainActor
class WeatherViewModel: NSObject {
    private static let lastSearchedLocationKey = "lastSearchedLocation"
    
    private let weatherProvider: WeatherProviderContract
    private let geocodingProvider: GeocodingProviderContract
    private let locationManager: CLLocationManager
    
    var location: Location?
    var currentWeather: CurrentWeather?
    
    var weatherLocation: String {
        location?.name ?? ""
    }
    
    var temperature: String {
        guard let temperature = currentWeather?.info.temperature else { return "" }
        return formattedTemperature(value: temperature)
    }
    
    var minTemperature: String {
        guard let temperature = currentWeather?.info.minTemperature else { return "" }
        return formattedTemperature(value: temperature)
    }
    
    var maxTemperature: String {
        guard let temperature = currentWeather?.info.maxTemperature else { return "" }
        return formattedTemperature(value: temperature)
    }
    
    var humidity: String {
        guard let humidity = currentWeather?.info.humidity else { return "" }
        return "\(humidity) %"
    }
    
    var onWeatherLoad: (() -> Void)?
    
    init(weatherProvider: WeatherProviderContract = WeatherProvider(),
         geocodingProvider: GeocodingProviderContract = GeocodingProvider()) {
        
        self.weatherProvider = weatherProvider
        self.geocodingProvider = geocodingProvider
        self.locationManager = CLLocationManager()
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    // MARK: - Weather Loading
    
    func getCurrentWeather() async {
        guard let location = location else {
            self.onWeatherLoad?()
            return
        }
        
        if let weather = try? await weatherProvider.getCurrentWeather(latitude: location.lat, longitude: location.lon) {
            self.currentWeather = weather
        }
        
        self.onWeatherLoad?()
    }
    
    func getWeatherConditionIcon(name: String) async -> UIImage? {
        try? await weatherProvider.getWeatherConditionIcon(name: name)
    }
    
    // MARK: - Store Location
    
    @discardableResult
    func loadStoredLocation() -> Bool {
        guard let locationData = UserDefaults.standard.object(forKey: Self.lastSearchedLocationKey) as? Data,
              let lastLocation = try? JSONDecoder().decode(Location.self, from: locationData) else {
            return false
        }
        
        location = lastLocation
        return true
    }
    
    func storeLocation() {
        guard let location = location else { return }
        
        if let encoded = try? JSONEncoder().encode(location) {
            UserDefaults.standard.set(encoded, forKey: Self.lastSearchedLocationKey)
        }
    }
    
    // MARK: - Private
    
    private func loadStoredLocationWeather() async {
        loadStoredLocation()
        await getCurrentWeather()
    }
    
    private func loadUserLocationWeather(manager: CLLocationManager) async {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            // We could listen to user location updates and refresh based on that, but I don't think it's necessary for now
            guard let coordinate = manager.location?.coordinate, let location = try? await geocodingProvider.getCity(latitude: coordinate.latitude, longitude: coordinate.longitude) else {
                await loadStoredLocationWeather()
                return
            }
            
            self.location = location
            await getCurrentWeather()
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        default:
            await loadStoredLocationWeather()
            break
        }
    }
    
    private func formattedTemperature(value: Double) -> String {
        let f = MeasurementFormatter()
        
        // we could support dynamic locales and fetch the appropriate units from the weather API, but it's not needed right now
        return f.string(from: Measurement(value: value, unit: UnitTemperature.fahrenheit))
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    // https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/3563956-locationmanagerdidchangeauthoriz
    // As this method is always called upon CLLocationManager instantiation, we can piggyback on it to download weather data
    // after the viewModel instantiation.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { await loadUserLocationWeather(manager: manager) }
    }
}
