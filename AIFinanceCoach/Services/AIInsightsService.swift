import Foundation
import CoreData

struct AIInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: String
}

class AIInsightsService {
    static let shared = AIInsightsService()
    
    func generateInsights(from expenses: [ExpenseData]) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        guard !expenses.isEmpty else {
            return [AIInsight(title: "No data yet", description: "Add some expenses to see AI insights.", icon: "info.circle", color: "gray")]
        }
        
        // 1. Highest Expense Category
        let categoryTotals = Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        if let highest = categoryTotals.max(by: { $0.value < $1.value }) {
            insights.append(AIInsight(
                title: "Top Spending",
                description: "Your highest expense category is \(highest.key) with a total of \(formatCurrency(highest.value)).",
                icon: "chart.pie.fill",
                color: "orange"
            ))
        }
        
        // 2. Comparison with last week/month
        let now = Date()
        let calendar = Calendar.current
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: now)!
        let lastWeek = calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .weekOfYear, value: -1, to: now)!)!
        
        let thisWeekExpenses = expenses.filter { currentWeek.contains($0.date) }.reduce(0) { $0 + $1.amount }
        let lastWeekExpenses = expenses.filter { lastWeek.contains($0.date) }.reduce(0) { $0 + $1.amount }
        
        if lastWeekExpenses > 0 {
            let diff = ((thisWeekExpenses - lastWeekExpenses) / lastWeekExpenses) * 100
            if diff > 10 {
                insights.append(AIInsight(
                    title: "Spending Spike",
                    description: "You've spent \(Int(diff))% more this week compared to last week. Try to cut back on unnecessary expenses.",
                    icon: "arrow.up.right.circle.fill",
                    color: "red"
                ))
            } else if diff < -10 {
                insights.append(AIInsight(
                    title: "Great Job!",
                    description: "Your spending is down \(Int(abs(diff)))% this week. Keep up the good work!",
                    icon: "checkmark.circle.fill",
                    color: "green"
                ))
            }
        }
        
        // 3. Frequent Category
        let categoryCounts = Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.count }
        
        if let mostFrequent = categoryCounts.max(by: { $0.value < $1.value }) {
            insights.append(AIInsight(
                title: "Frequent Habits",
                description: "You made \(mostFrequent.value) transactions in \(mostFrequent.key) recently.",
                icon: "repeat.circle.fill",
                color: "blue"
            ))
        }
        
        return insights
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
