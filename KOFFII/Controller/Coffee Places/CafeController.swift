import UIKit

class CafeController {
    
    struct Cafe: Hashable {
        let name: String
        let latitude: Double?
        let longitude: Double?
        let locationURL: String?
        let features: [String: Bool]?
        let hood: String?
        
        private let identifier: UUID
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }

        init?(dictionary: [String: Any]) {
            guard let name = dictionary["name"] as? String else { return nil }
            self.name = name

            latitude = dictionary["latitude"] as? Double
            longitude = dictionary["longitude"] as? Double
            locationURL = dictionary["locationURL"] as? String
            features = dictionary["features"] as? [String: Bool]
            hood = dictionary["hood"] as? String
            self.identifier = UUID()
        }
    }
    
    func filteredCafes(cafes: [Cafe],userRequestedFeatures: [Feature],userChoosenNeighborhoods: [Neighborhood],with filter: String?=nil) -> [Cafe] {
        var filtered = cafes
        for feature in Feature.allCases {
            if userRequestedFeatures.contains(feature) {
                filtered = filtered.filter { $0.features![feature.rawValue] == true }
            }
        }
        for neighborhood in Neighborhood.allCases {
            if userChoosenNeighborhoods.contains(neighborhood) {
                filtered = filtered.filter { $0.hood == neighborhood.rawValue }
            }
        }
        return filtered
    }
    
}
