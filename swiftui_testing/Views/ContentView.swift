import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        VStack {
            Spacer()
            HeaderView(score: $viewModel.score)
            Spacer(minLength: 10)
            BoardView(flattenedBoard: $viewModel.flattenedBoard, numberOfTiles: ViewModel.numberOfTiles)
            Spacer()
            GameControlsView(viewModel: viewModel)

        }
        .padding()
        .gesture(
            DragGesture(
                minimumDistance: 100,
                coordinateSpace: .global
            ).onEnded { value in
                handleGesture(value)
            }
        )
    }
}

#Preview {
    let viewModel = ViewModel()
    ContentView(viewModel: viewModel)
}

private extension ContentView {
    enum SwipeDirection {
        case left
        case right
        case up
        case down
    }

    func handleGesture(_ value: DragGesture.Value) {
        let direction = detectDirection(value.translation)
        withAnimation(.easeInOut(duration: 0.1)) {
            switch direction {
            case .down:
                viewModel.down()
            case .up:
                viewModel.up()
            case .left:
                viewModel.left()
            case .right:
                viewModel.right()
            }
        }
    }

    func detectDirection(_ value: CGSize) -> SwipeDirection {
        if abs(value.width) > abs(value.height) {
            return value.width > 0 ? .right : .left
        } else {
            return value.height > 0 ? .down : .up
        }
    }
}
