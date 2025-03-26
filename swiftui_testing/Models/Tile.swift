import Foundation

struct Tile: Hashable, Equatable {
    let id: UUID
    var value: Int

    init(id: UUID = UUID(), value: Int = 0) {
        self.id = id
        self.value = value
    }

    mutating func updateValue(_ value: Int) {
        self.value = value
    }

    mutating func doubleValue() {
        self.value *= 2
    }

    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.id == rhs.id
    }
}
