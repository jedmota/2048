import Foundation
import SwiftData

@Model
class TileSwiftData: Tile {
    private(set) var id: String
    var value: Int

    init(id: String = UUID().uuidString, value: Int = 0) {
        self.id = id
        self.value = value
    }
    
    // Required initializer for decoding (conforms to Codable)
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.value = try container.decode(Int.self, forKey: .value)
    }

    // Encoding method (conforms to Codable)
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .value)
    }

    // Coding keys to match properties for encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case value
    }

    func updateValue(_ value: Int) {
        self.value = value
    }

    func doubleValue() {
        self.value *= 2
    }

//    static func == (lhs: TileSwiftData, rhs: TileSwiftData) -> Bool {
//        return lhs.id == rhs.id
//    }
}
