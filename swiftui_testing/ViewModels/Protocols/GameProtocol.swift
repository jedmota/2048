import Foundation

protocol GameProtocol: ObservableObject {
    func back()
    func next()
    func newGame()
    func hasNext() -> Bool
    func hasPrevious() -> Bool
}
