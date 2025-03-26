import SwiftUI

final class ViewModel: GameProtocol, ObservableObject {

    static let numberOfTiles: Int = 4
    @Published var board: [[Tile]] = Array(repeating: Array(repeating: .init(), count: numberOfTiles), count: numberOfTiles)
    {
        didSet {
            flattenedBoard = board.flatMap { $0 }
        }
    }
    @Published var score: Int = 0
    @Published var new: [CGPoint] = []
    @Published var flattenedBoard: [Tile] = []

    lazy var zeros: [[UUID]] = {
        (0..<Self.numberOfTiles).map { _ in (0..<Self.numberOfTiles).map { _ in UUID() } }
    }()

    struct State {
        let board: [[Tile]]
        let score: Int
        let new: [CGPoint]
    }
    var snapshot: State { .init(board: board, score: score, new: new) }
    var history: [State] = []
    var index: Int = 0

    init() {
        newGame()
    }

    func newGame() {
        board = (0..<Self.numberOfTiles).map { row in (0..<Self.numberOfTiles).map { column in Tile(id: zeros[row][column]) } }
        score = 0
        index = 0
        addTile()
        index = 0
        history = []
        addTile()
        index = 0
    }

    func addTile() {
        let point = getOneRandomEmptyTilePoint()
        board[Int(point.y)][Int(point.x)] = .init(value: 2)
        new = [point]
        index += 1
        if history.count < index + 1 {
            history.append(snapshot)
        } else {
            history.insert(snapshot, at: index)
        }
    }

    func back() {
        guard index > 0 else { return }
        index -= 1
        updateHistory()
    }

    func next() {
        guard history.count > index + 1 else { return }
        index += 1
        updateHistory()
    }

    func updateHistory() {
        board = history[index].board
        score = history[index].score
        new = history[index].new
    }

    func dropHistoryAfterIndex() {
        let snapsToRemove = history.count - (index + 1)
        history = history.dropLast(snapsToRemove)
    }

    func up() {
        var moved = false
        for i in 0..<Self.numberOfTiles {
            moved = moveUp(i) || moved
        }
        if moved {
            addTile()
            dropHistoryAfterIndex()
        }
    }

    func down() {
        var moved = false
        for i in 0..<Self.numberOfTiles {
            moved = moveDown(i) || moved
        }
        if moved {
            addTile()
            dropHistoryAfterIndex()
        }
    }

    func right() {
        var moved = false
        for i in 0..<Self.numberOfTiles {
            moved = moveRight(i) || moved
        }
        if moved {
            addTile()
            dropHistoryAfterIndex()
        }
    }

    func left() {
        var moved = false
        for i in 0..<Self.numberOfTiles {
            moved = moveLeft(i) || moved
        }
        if moved {
            addTile()
            dropHistoryAfterIndex()
        }
    }

    func isNew(_ point: CGPoint) -> Bool {
        new.contains(point)
    }

    func hasNext() -> Bool {
        !history.isEmpty && index < history.count - 1
    }

    func hasPrevious() -> Bool {
        index > 0
    }
}

private extension ViewModel {
    func getColumn(_ column: Int) -> [Tile] {
        return board.map {
            $0[column]
        }
    }

    func setColumn(_ column: Int, _ tiles: [Tile]) {
        board.indices.forEach { i in
            board[i][column] = tiles[i]
        }
    }

    func moveUp(_ column: Int) -> Bool {
        let tiles = getColumn(column)
        var newTiles: [Tile] = tiles.filter { $0.value != 0 }
        newTiles = sumEqualValuesInSequence(tiles: newTiles)
        newTiles.append(contentsOf: (0..<(Self.numberOfTiles-newTiles.count)).map { row in Tile(id: zeros[newTiles.count + row][column], value: 0) } )
        setColumn(column, newTiles)
        return tiles.map { $0.value } != newTiles.map { $0.value }
    }

    func moveDown(_ column: Int) -> Bool {
        let tiles = getColumn(column)
        var newTiles: [Tile] = tiles.filter { $0.value != 0 }
        newTiles = sumEqualValuesInSequence(tiles: newTiles.reversed()).reversed()
        var final = (0..<(Self.numberOfTiles-newTiles.count)).map { row in Tile(id: zeros[row][column], value: 0) }
        final.append(contentsOf: newTiles)
        setColumn(column, final)
        return tiles.map { $0.value } != final.map { $0.value }
    }

    func moveRight(_ row: Int) -> Bool {
        let tiles = board[row]
        var newTiles: [Tile] = tiles.filter { $0.value != 0 }
        newTiles = sumEqualValuesInSequence(tiles: newTiles.reversed()).reversed()
        var final = (0..<(Self.numberOfTiles-newTiles.count)).map { column in Tile(id: zeros[row][column], value: 0) }
        final.append(contentsOf: newTiles)
        board[row] = final
        return tiles.map { $0.value } != final.map { $0.value }
    }

    func moveLeft(_ row: Int) -> Bool {
        let tiles = board[row]
        var newTiles: [Tile] = tiles.filter { $0.value != 0 }
        newTiles = sumEqualValuesInSequence(tiles: newTiles)
        newTiles.append(contentsOf: (0..<(Self.numberOfTiles-newTiles.count)).map { column in Tile(id: zeros[row][newTiles.count + column], value: 0) } )
        board[row] = newTiles
        return tiles.map { $0.value } != newTiles.map { $0.value }
    }

    func sumEqualValuesInSequence(tiles: [Tile]) -> [Tile] {
        var lastValue: Int?
        var result: [Tile] = []
        for tile in tiles {
            var tile = tile
            if lastValue == tile.value {
                result = result.dropLast()
                tile.doubleValue()
                result.append(tile)
                score += tile.value
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
