import Foundation

protocol Game {
    var history: [GameState] { get set }
    var index: Int { get set }
    
    var actualBoard: [[any Tile]] { get }
    var actualScore: Int { get }
    var actualNew: [CGPoint] { get }
    
    func dropHistoryAfterIndex()
    func snapshot(_ snapshot: GameState)
    func hasNext() -> Bool
    func hasPrevious() -> Bool
    func backIfPossible() -> Bool
    func nextIfPossible() -> Bool
}
