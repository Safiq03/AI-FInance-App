import SwiftUI

struct LockView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.top, 100)
            
            Text("AI Finance Coach is Locked")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Unlock to access your financial data")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                viewModel.authenticate()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Unlock with Biometrics")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.authenticate()
        }
    }
}
