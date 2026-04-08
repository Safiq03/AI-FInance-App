import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FinanceViewModel
    
    @State private var amount = ""
    @State private var selectedCategory: Category = .others
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Category.allCases) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Notes")) {
                    TextField("What did you buy?", text: $notes)
                        .onChange(of: notes) { newValue in
                            let suggested = CategorizationService.shared.suggestCategory(for: newValue)
                            if suggested != .others {
                                selectedCategory = suggested
                            }
                        }
                    
                    if CategorizationService.shared.suggestCategory(for: notes) != .others {
                        Text("Suggested category based on notes")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amountDouble = Double(amount) {
                            viewModel.addExpense(amount: amountDouble, category: selectedCategory, date: date, notes: notes)
                            dismiss()
                        }
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
}
