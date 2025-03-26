import SwiftUI

struct HeaderView: View {

    @Binding var score: Int

    var body: some View {
        HStack {
            Spacer(minLength: 10)
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text("Score")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.9))
                    Text("\(score)")
                        .font(.system(size: 90))
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 5)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .border(.gray.opacity(0.3), width: 0.5)
            Spacer(minLength: 10)
        }
    }
}

#Preview {
    HeaderView(score: .constant(1024))
}
