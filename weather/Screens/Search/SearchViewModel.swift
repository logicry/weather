//
//  SearchViewModel.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import Foundation

@MainActor
class SearchLocationViewModel {
    private let geocodingProvider: GeocodingProviderContract
    
    init(geocodingProvider: GeocodingProviderContract = GeocodingProvider()) {
        self.geocodingProvider = geocodingProvider
    }
    
    func getLocation(of city: String) async -> Location? {
        guard city.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else { return nil }
        
        return try? await self.geocodingProvider.getLocation(of: city)
    }
}
