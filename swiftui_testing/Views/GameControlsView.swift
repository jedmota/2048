import SwiftUI

struct GameControlsView<ViewModel: GameProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        HStack(spacing: 20) {
            Button("<") {
                withAnimation {
                    viewModel.back()
                }
            }
            .frame(width: 60, height: 50)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(4)
            .foregroundColor(viewModel.hasPrevious() ? Color.white : Color.gray.opacity(0.6))
            .font(.title3)
            Button("New Game") {
                withAnimation {
                    viewModel.newGame()
                }
            }
            .frame(width: 160, height: 50)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(8)
            .foregroundColor(Color.white)
            .font(.title3)
            Button(">") {
                withAnimation {
                    viewModel.next()
                }
            }
            .frame(width: 60, height: 50)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(4)
            .foregroundColor(viewModel.hasNext() ? Color.white : Color.gray.opacity(0.6))
            .font(.title3)
        }
    }
}

//#Preview {
//    struct MockGameControls: GameProtocol {
//        func back() {}
//        func next() {}
//        func newGame() {}
//        func hasNext() -> Bool { true }
//        func hasPrevious() -> Bool { true }
//    }
//    GameControlsView(viewModel: MockGameControls())
//}
