import Foundation


struct Complain{
    let name: String
    let improvements: Array<String>?
    
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else { return nil }
        self.name = name
        
        self.improvements = dictionary["improvements"] as? Array<String>
    }
}
