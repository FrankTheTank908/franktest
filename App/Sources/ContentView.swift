import SwiftUI

struct ContentView: View {
    @State private var showYay = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Frank the Tank")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 6)

                Button("Push me") {
                    showYay = true
                }
                .font(.title3.bold())
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.purple)
            }
            .padding()
        }
        .alert("Yay!", isPresented: $showYay) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You pressed the button.")
        }
    }
}

#Preview {
    ContentView()
}
