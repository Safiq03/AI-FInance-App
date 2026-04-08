import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    summaryCard
                    
                    Text("AI Insights")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    insightsCarousel
                    
                    spendingChart
                        .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                    
                    VStack(spacing: 4) {
                        Text("AI Finance Coach")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("Developed with ❤️ by Safiq")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("AI Coach")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
        }
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Spent This Month")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            let total = viewModel.totalSpentCurrentMonth
            Text(formatCurrency(total))
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            ProgressView(value: min(total, viewModel.monthlyBudget), total: viewModel.monthlyBudget)
                .accentColor(total > viewModel.monthlyBudget ? .red : .green)
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 5)
            
            HStack {
                Text("Budget: \(formatCurrency(viewModel.monthlyBudget))")
                Spacer()
                let remaining = viewModel.monthlyBudget - total
                Text(remaining >= 0 ? "\(formatCurrency(remaining)) left" : "\(formatCurrency(abs(remaining))) over")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
        }
        .padding(24)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    private var insightsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                if viewModel.insights.isEmpty {
                    Text("No insights available yet.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(viewModel.insights) { insight in
                        InsightCard(insight: insight)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spending Trends")
                .font(.title2)
                .fontWeight(.bold)
            
            if viewModel.expenses.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No spending data yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            } else {
                Chart {
                    ForEach(viewModel.chartData) { data in
                        BarMark(
                            x: .value("Day", data.date, unit: .day),
                            y: .value("Amount", data.amount)
                        )
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

struct InsightCard: View {
    let insight: AIInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: insight.icon)
                    .foregroundColor(getColor(insight.color))
                    .font(.title3)
                Spacer()
            }
            
            Text(insight.title)
                .font(.headline)
            
            Text(insight.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)
        }
        .padding()
        .frame(width: 180, height: 140)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    func getColor(_ colorName: String) -> Color {
        switch colorName {
        case "orange": return .orange
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        default: return .gray
        }
    }
}
