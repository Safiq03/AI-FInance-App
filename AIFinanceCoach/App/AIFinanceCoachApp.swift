import SwiftUI
import CoreData

@main
struct AIFinanceCoachApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var viewModel = FinanceViewModel()

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

struct SplashScreen: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var size = 0.8
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var viewModel: FinanceViewModel
    
    var body: some View {
        if isActive {
            ContentView_Bridge()
        } else {
            ZStack {
                Color(white: 0.05).edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 8) {
                            Text("AI Finance Coach")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Your Intelligent Wealth Partner")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                    
                    VStack(spacing: 4) {
                        Text("Developed by")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Safiq")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .tracking(2)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct ContentView_Bridge: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        Group {
            if viewModel.isAppLocked {
                LockView()
            } else {
                MainTabView()
                    .environment(\.managedObjectContext, context)
            }
        }
    }
}
