import SwiftUI

struct BoardView: View {
    @Namespace private var animation
    @Binding var flattenedBoard: [Tile]
    let numberOfTiles: Int

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(Constants.tileSize)), count: numberOfTiles), spacing: 10) {
            ForEach(flattenedBoard, id: \.id) { tile in
                Text("\(tile.value == 0 ? "" : "\(tile.value)")")
                    .frame(width: Constants.tileSize, height: Constants.tileSize)
                    .background(tileBackgroundColor(value: tile.value))
                    .border(.gray.opacity(0.6), width: 0.5)
                    .cornerRadius(6)
                    .matchedGeometryEffect(id: tile.id, in: animation)
                    .font(.title)
                    .foregroundColor(.black)
            }
        }
    }
}

private extension BoardView {
    enum Constants {
        static let tileSize = 75.0
    }
    
    func tileBackgroundColor(value: Int) -> Color {
        switch level(from: value) {
        case 0:
            return .gray.opacity(0.4)
        case 1:
            return .yellow
        case 2:
            return .orange
        case 3:
            return .purple
        case 4:
            return .blue
        case 5:
            return .green
        case 6:
            return .red
        case 7:
            return .brown
        case 8:
            return .cyan
        case 9:
            return .indigo
        case 10:
            return .mint
        case 11:
            return .pink
        case 12:
            return .teal
        default:
            return .white
        }
    }

    func level(from value: Int) -> Int {
        var level = 0
        var num = value
        while num > 1 {
            num /= 2
            level += 1
        }
        return level
    }

}
