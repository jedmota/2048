import Foundation

protocol GameState: Codable {
    var board: [[any Tile]] { get set }
    var score: Int { get set }
    var new: [CGPoint] { get set }
}
