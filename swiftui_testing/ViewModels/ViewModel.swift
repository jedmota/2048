import SwiftUI

final class ViewModel: GameProtocol, ObservableObject {

    static let numberOfTiles: Int = 4
    @Published var board: [[any Tile]] = Array(repeating: Array(repeating: EmptyTile(), count: numberOfTiles), count: numberOfTiles)
    {
        didSet {
            flattenedBoard = board.flatMap { $0 }
        }
    }
    @Published var score: Int = 0
    @Published var new: [CGPoint] = []
    @Published var flattenedBoard: [any Tile] = []
    
    var game: Game = EmptyGame()

    init() {
        newGame()
    }

    func newGame() {
        board = (0..<Self.numberOfTiles).map { row in (0..<Self.numberOfTiles).map { column in EmptyTile(row: row, column: column) } }
        score = 0
        game.index = 0
        game.history = []
        let point1 = addTile()
        let point2 = addTile()
        new = [point1, point2]
        game.history.append(EmptyGameState(board: board, score: score, new: new))
    }

    func addTile() -> CGPoint {
        let point = getOneRandomEmptyTilePoint()
        board[Int(point.y)][Int(point.x)] = EmptyTile(value: 2)
        return point
    }
    
    func addTileAndIterate() {
        let point = addTile()
        new = [point]
        let snapshot = EmptyGameState(board: board, score: score, new: new)
        game.snapshot(snapshot)
    }

    func back() {
        guard game.backIfPossible() else { return }
        updateHistory()
    }

    func next() {
        guard game.nextIfPossible() else { return }
        updateHistory()
    }

    func up() {
        var moved = false
        for i in 0..<Self.numberOfTiles {
            moved = moveUp(i) || moved
        }
        if moved {
            addTileAndIterate()
            game.dropHistoryAfterIndex()
        }
    }

    func down() {
        var moved = false
        for i in 0..<Self.numberOfTiles {
            moved = moveDown(i) || moved
        }
        if moved {
            addTileAndIterate()
            game.dropHistoryAfterIndex()
        }
    }

    func right() {
        var moved = false
        for i in 0..<Self.numberOfTiles {
            moved = moveRight(i) || moved
        }
        if moved {
            addTileAndIterate()
            game.dropHistoryAfterIndex()
        }
    }

    func left() {
        var moved = false
        for i in 0..<Self.numberOfTiles {
            moved = moveLeft(i) || moved
        }
        if moved {
            addTileAndIterate()
            game.dropHistoryAfterIndex()
        }
    }

    func isNew(_ point: CGPoint) -> Bool {
        new.contains(point)
    }

    func hasNext() -> Bool {
        return game.hasNext()
    }

    func hasPrevious() -> Bool {
        return game.hasPrevious()
    }
}

private extension ViewModel {
    func updateHistory() {
        board = game.actualBoard
        score = game.actualScore
        new = game.actualNew
    }
    
    func getColumn(_ column: Int) -> [any Tile] {
        return board.map {
            $0[column]
        }
    }

    func setColumn(_ column: Int, _ tiles: [any Tile]) {
        board.indices.forEach { i in
            board[i][column] = tiles[i]
        }
    }

    func moveUp(_ column: Int) -> Bool {
        let tiles = getColumn(column)
        var newTiles: [any Tile] = tiles.filter { $0.value != 0 }
        newTiles = sumEqualValuesInSequence(tiles: newTiles)
        newTiles.append(contentsOf: (0..<(Self.numberOfTiles-newTiles.count)).map { row in EmptyTile(row: newTiles.count + row, column: column) } )
        setColumn(column, newTiles)
        return tiles.map { $0.value } != newTiles.map { $0.value }
    }

    func moveDown(_ column: Int) -> Bool {
        let tiles = getColumn(column)
        var newTiles: [any Tile] = tiles.filter { $0.value != 0 }
        newTiles = sumEqualValuesInSequence(tiles: newTiles.reversed()).reversed()
        var final: [any Tile] = (0..<(Self.numberOfTiles-newTiles.count)).map { row in EmptyTile(row: row, column: column) }
        final.append(contentsOf: newTiles)
        setColumn(column, final)
        return tiles.map { $0.value } != final.map { $0.value }
    }

    func moveRight(_ row: Int) -> Bool {
        let tiles = board[row]
        var newTiles: [any Tile] = tiles.filter { $0.value != 0 }
        newTiles = sumEqualValuesInSequence(tiles: newTiles.reversed()).reversed()
        var final: [any Tile] = (0..<(Self.numberOfTiles-newTiles.count)).map { column in EmptyTile(row: row, column: column) }
        final.append(contentsOf: newTiles)
        board[row] = final
        return tiles.map { $0.value } != final.map { $0.value }
    }

    func moveLeft(_ row: Int) -> Bool {
        let tiles = board[row]
        var newTiles: [any Tile] = tiles.filter { $0.value != 0 }
        newTiles = sumEqualValuesInSequence(tiles: newTiles)
        newTiles.append(contentsOf: (0..<(Self.numberOfTiles-newTiles.count)).map { column in EmptyTile(row: row, column: newTiles.count + column) } )
        board[row] = newTiles
        return tiles.map { $0.value } != newTiles.map { $0.value }
    }

    func sumEqualValuesInSequence(tiles: [any Tile]) -> [any Tile] {
        var lastValue: Int?
        var result: [any Tile] = []
        for tile in tiles {
            if lastValue == tile.value {
                result = result.dropLast()
                let newTile = EmptyTile(id: tile.id, value: tile.value * 2)
                result.append(newTile)
                score += newTile.value
                lastValue = nil
            } else {
                result.append(tile)
                lastValue = tile.value
            }
        }
        return result
    }

    func getEmptyTilesCount() -> Int {
        return board.flatMap(\.self).filter { $0.value == 0 }.count
    }

    func getEmptyTilePoints() -> [CGPoint] {
        return board.enumerated().flatMap { row, rowValues in
            rowValues.enumerated().compactMap { col, tile in
                tile.value == 0 ? CGPoint(x: col, y: row) : nil
            }
        }
    }

    func getOneRandomEmptyTilePoint() -> CGPoint {
        let getEmptyTilePoints: [CGPoint] = self.getEmptyTilePoints()
        guard !getEmptyTilePoints.isEmpty else {
            fatalError("No empty tiles")
        }
        return getEmptyTilePoints.randomElement()!
    }
}

class EmptyTile: Tile {
    private(set) var id: String
    var value: Int
    
    init(id: String = UUID().uuidString, value: Int = 0) {
        self.id = id
        self.value = value
    }
    
    convenience init(row: Int, column: Int) {
        self.init(id: "empty_id:\(row),\(column)", value: 0)
    }
    
    static func == (lhs: EmptyTile, rhs: EmptyTile) -> Bool {
        return lhs.id == rhs.id
    }
}

class EmptyGameState: GameState {
    var board: [[any Tile]]
    var score: Int
    var new: [CGPoint]
    
    init(board: [[any Tile]], score: Int, new: [CGPoint]) {
        self.board = board
        self.score = score
        self.new = new
    }
    
    // Required initializer for decoding (conforms to Codable)
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.board = try container.decode([[EmptyTile]].self, forKey: .board)
        self.score = try container.decode(Int.self, forKey: .score)
        self.new = try container.decode([CGPoint].self, forKey: .new)
    }

    // Encoding method (conforms to Codable)
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encode the board as an array of arrays of TileData
        let boardData = board.map { row in
            row.map { tile in
                EmptyTile(id: tile.id, value: tile.value)
            }
        }
        try container.encode(boardData, forKey: .board)
        try container.encode(score, forKey: .score)
        try container.encode(new, forKey: .new)
    }

    // Coding keys to match properties for encoding/decoding
    enum CodingKeys: String, CodingKey {
        case board
        case score
        case new
    }
}

class EmptyGame: Game {
    var history: [GameState] {
        didSet {
            print("###", "history.count", history.count)
        }
    }
    var index: Int {
        didSet {
            print("###", "index", index)
        }
    }
    var actualBoard: [[any Tile]] { history[index].board }
    var actualScore: Int { history[index].score }
    var actualNew: [CGPoint] { history[index].new }
    
    init() {
        history = []
        index = 0
    }
    
    func dropHistoryAfterIndex() {
        let snapsToRemove = history.count - (index + 1)
        guard snapsToRemove > 0 else { return }
        history = history.dropLast(snapsToRemove)
    }
    
    func snapshot(_ snapshot: any GameState) {
        index += 1
        if history.count < index + 1 {
            history.append(snapshot)
        } else {
            history.insert(snapshot, at: index)
        }
    }
    
    func hasNext() -> Bool {
        !history.isEmpty && index < history.count - 1
    }

    func hasPrevious() -> Bool {
        index > 0
    }
    
    func backIfPossible() -> Bool {
        guard index > 0 else { return false}
        index -= 1
        return true
    }

    func nextIfPossible() -> Bool {
        guard history.count > index + 1 else { return false }
        index += 1
        return true
    }
}
