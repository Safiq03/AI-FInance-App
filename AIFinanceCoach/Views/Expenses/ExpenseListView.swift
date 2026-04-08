import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.expenses.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Expenses Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Add your first expense to see analytics and get AI insights.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(viewModel.groupedExpenses, id: \.0) { date, expenses in
                        Section(header: Text(formatDate(date))) {
                            ForEach(expenses) { expense in
                                ExpenseRow(expense: expense)
                            }
                            .onDelete { indexSet in
                                deleteExpense(at: indexSet, from: expenses)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Expenses")
        }
    }
    
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }
    
    private func deleteExpense(at offsets: IndexSet, from list: [Expense]) {
        for index in offsets {
            let expense = list[index]
            viewModel.deleteExpense(expense)
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 15) {
            let category = Category(rawValue: expense.category ?? "Others") ?? .others
            
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.notes ?? "No notes")
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(expense.category ?? "Others")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatCurrency(expense.amount))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
