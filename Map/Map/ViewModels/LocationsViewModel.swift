//
//  LocationsViewModel.swift
//  Map
//
//  Created by 김동락 on 2023/01/03.
//

import Foundation

class LocationsViewModel: ObservableObject {
    @Published var locations: [Location]
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
    }
}
