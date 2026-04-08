import Foundation

enum ChatSender {
    case user
    case ai
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let sender: ChatSender
    let timestamp = Date()
}

class ChatService {
    static let shared = ChatService()
    
    func getResponse(for message: String, expenses: [Expense]) -> String {
        let input = message.lowercased()
        
        if input.contains("how did i spend this week") || input.contains("spending this week") {
            let calendar = Calendar.current
            let currentWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!
            let total = expenses.filter { currentWeek.contains($0.date ?? Date()) }.reduce(0) { $0 + $1.amount }
            return "You've spent \(formatCurrency(total)) this week. Would you like to see the breakdown by category?"
        }
        
        if input.contains("where can i save money") || input.contains("save money") {
            let categoryTotals = Dictionary(grouping: expenses, by: { $0.category ?? "Others" })
                .mapValues { $0.reduce(0) { $0 + $1.amount } }
            
            if let highest = categoryTotals.max(by: { $0.value < $1.value }) {
                return "You are spending the most on \(highest.key) (\(formatCurrency(highest.value))). Reducing expenses in this category could help you save significant money."
            }
            return "Try setting a monthly budget limit in settings to track your savings goals."
        }
        
        if input.contains("total balance") || input.contains("total spent") {
            let total = expenses.reduce(0) { $0 + $1.amount }
            return "Your total recorded spending is \(formatCurrency(total))."
        }
        
        if input.contains("hello") || input.contains("hi") {
            return "Hello! I'm your AI Finance Coach. You can ask me about your spending this week, where to save money, or your total expenses."
        }
        
        return "I'm not sure I understand that. Try asking 'How did I spend this week?' or 'Where can I save money?'"
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
