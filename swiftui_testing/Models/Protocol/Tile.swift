import Foundation

protocol Tile: Equatable, Codable {
    var id: String { get }
    var value: Int { get set }
}
