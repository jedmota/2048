//import Foundation
//import SwiftData
//
//@Model
//class GameStateSwiftData: GameState, Codable {
//    var board: [[any Tile]]
//    var score: Int
//    var new: [CGPoint]
//    
//    init(board: [[any Tile]], score: Int, new: [CGPoint]) {
//        self.board = board
//        self.score = score
//        self.new = new
//    }
//    
//    // Required initializer for decoding (conforms to Codable)
//    required init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.board = try container.decode([[TileSwiftData]].self, forKey: .board)
//        self.score = try container.decode(Int.self, forKey: .score)
//        self.new = try container.decode([CGPoint].self, forKey: .new)
//    }
//
//    // Encoding method (conforms to Codable)
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        // Encode the board as an array of arrays of TileData
//        let boardData = board.map { row in
//            row.map { tile in
//                TileSwiftData(id: tile.id, value: tile.value)
//            }
//        }
//        try container.encode(boardData, forKey: .board)
//        try container.encode(score, forKey: .score)
//        try container.encode(new, forKey: .new)
//    }
//
//    // Coding keys to match properties for encoding/decoding
//    enum CodingKeys: String, CodingKey {
//        case board
//        case score
//        case new
//    }
//}
