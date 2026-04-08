import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showingEditBudget = false
    @State private var newBudgetText = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Balance & Budget")) {
                    HStack {
                        Label("Monthly Budget", systemImage: "dollarsign.circle")
                        Spacer()
                        Text(formatCurrency(viewModel.monthlyBudget))
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        newBudgetText = String(viewModel.monthlyBudget)
                        showingEditBudget = true
                    }
                }
                
                Section(header: Text("Security")) {
                    Toggle(isOn: $viewModel.isBiometricEnabled) {
                        Label("Face ID / Touch ID", systemImage: "faceid")
                    }
                }
                
                Section(header: Text("App Info")) {
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Safiq")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Edit Monthly Budget", isPresented: $showingEditBudget) {
                TextField("Amount", text: $newBudgetText)
                    .keyboardType(.decimalPad)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if let new = Double(newBudgetText) {
                        viewModel.monthlyBudget = new
                    }
                }
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
