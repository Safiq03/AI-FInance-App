import Foundation
import CoreData
import SwiftUI
import Combine
import LocalAuthentication

struct DailySpending: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct ExpenseData {
    let amount: Double
    let date: Date
    let category: String
}

class FinanceViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var insights: [AIInsight] = []
    @Published var chatMessages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var chartData: [DailySpending] = []
    @Published var totalSpentCurrentMonth: Double = 0
    @Published var groupedExpenses: [(Date, [Expense])] = []
    
    // Settings
    @Published var monthlyBudget: Double {
        didSet {
            UserDefaults.standard.set(monthlyBudget, forKey: "monthlyBudget")
        }
    }
    
    @Published var isBiometricEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBiometricEnabled, forKey: "isBiometricEnabled")
        }
    }
    
    @Published var isAppLocked = false
    
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        self.monthlyBudget = UserDefaults.standard.double(forKey: "monthlyBudget")
        self.isBiometricEnabled = UserDefaults.standard.bool(forKey: "isBiometricEnabled")
        
        if self.monthlyBudget == 0 {
            self.monthlyBudget = 2000.0 // Default budget
        }
        
        if isBiometricEnabled {
            isAppLocked = true
        }
        
        fetchExpenses()
        
        // Initial AI message with Developer Signature
        chatMessages.append(ChatMessage(text: "Hello! I'm your AI Finance Coach, developed by Safiq. How can I help you today?", sender: .ai))
    }
    
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = NSFetchRequest(entityName: "Expense")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        // 1. Quick fetch for the main UI list
        do {
            let fetchedExpenses = try context.fetch(request)
            self.expenses = fetchedExpenses
            
            // 2. Offload heavy grouping and AI analysis to a background queue
            // We use NSManagedObjectIDs to transfer objects safely between threads
            let objectIDs = fetchedExpenses.map { $0.objectID }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let privateContext = PersistenceController.shared.container.newBackgroundContext()
                
                privateContext.perform {
                    var safeData: [ExpenseData] = []
                    var safeModelObj: [Expense] = []
                    
                    for id in objectIDs {
                        if let obj = try? privateContext.existingObject(with: id) as? Expense {
                            safeData.append(ExpenseData(
                                amount: obj.amount,
                                date: obj.date ?? Date(),
                                category: obj.category ?? "Others"
                            ))
                            safeModelObj.append(obj)
                        }
                    }
                    
                    let insights = AIInsightsService.shared.generateInsights(from: safeData)
                    let chart = self.calculateChartData(from: safeData)
                    let total = self.calculateMonthTotal(from: safeData)
                    let grouped = self.groupExpensesOnBg(safeData, source: fetchedExpenses)
                    
                    DispatchQueue.main.async {
                        self.insights = insights
                        self.chartData = chart
                        self.totalSpentCurrentMonth = total
                        self.groupedExpenses = grouped
                    }
                }
            }
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }
    
    private func groupExpensesOnBg(_ safeData: [ExpenseData], source: [Expense]) -> [(Date, [Expense])] {
        let grouped = Dictionary(grouping: source) { (expense) -> Date in
            Calendar.current.startOfDay(for: expense.date ?? Date())
        }
        return grouped.sorted(by: { $0.key > $1.key })
    }
    
    private func calculateChartData(from source: [ExpenseData]) -> [DailySpending] {
        let calendar = Calendar.current
        var results: [DailySpending] = []
        
        for i in (0..<7).reversed() {
            let day = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayInterval = calendar.dateInterval(of: .day, for: day)!
            let total = source
                .filter { dayInterval.contains($0.date) }
                .reduce(0) { $0 + $1.amount }
            results.append(DailySpending(date: day, amount: total))
        }
        return results
    }
    
    private func calculateMonthTotal(from source: [ExpenseData]) -> Double {
        let calendar = Calendar.current
        let currentMonth = calendar.dateInterval(of: .month, for: Date())!
        return source
            .filter { currentMonth.contains($0.date) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func groupExpenses(_ source: [Expense]) -> [(Date, [Expense])] {
        let grouped = Dictionary(grouping: source) { (expense) -> Date in
            Calendar.current.startOfDay(for: expense.date ?? Date())
        }
        return grouped.sorted(by: { $0.key > $1.key })
    }
    
    func addExpense(amount: Double, category: Category, date: Date, notes: String) {
        PersistenceController.shared.container.performBackgroundTask { context in
            guard let entity = NSEntityDescription.entity(forEntityName: "Expense", in: context) else { return }
            let newExpense = Expense(entity: entity, insertInto: context)
            newExpense.id = UUID()
            newExpense.amount = amount
            newExpense.category = category.rawValue
            newExpense.date = date
            newExpense.notes = notes
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.fetchExpenses()
                    self.checkBudgetAlert(for: amount)
                }
            } catch {
                print("Error saving background context: \(error)")
            }
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        let objectID = expense.objectID
        PersistenceController.shared.container.performBackgroundTask { context in
            if let objToDelete = try? context.existingObject(with: objectID) {
                context.delete(objToDelete)
                try? context.save()
                DispatchQueue.main.async {
                    self.fetchExpenses()
                }
            }
        }
    }
    
    func updateExpense(_ expense: Expense, amount: Double, category: Category, date: Date, notes: String) {
        expense.amount = amount
        expense.category = category.rawValue
        expense.date = date
        expense.notes = notes
        
        saveContext()
        fetchExpenses()
    }
    
    func sendChatMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        let userMessage = ChatMessage(text: text, sender: .user)
        chatMessages.append(userMessage)
        
        let aiResponseText = ChatService.shared.getResponse(for: text, expenses: expenses)
        let aiMessage = ChatMessage(text: aiResponseText, sender: .ai)
        
        // Simulate thinking delay
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isTyping = false
            self.chatMessages.append(aiMessage)
        }
    }
    
    func updateChartData() {
        // Obsolete: Replaced by background calculation in fetchExpenses
    }
    
    func generateInsights() {
        // Obsolete: Replaced by background calculation in fetchExpenses
    }
    
    private func saveContext() {
        PersistenceController.shared.save()
    }
    
    private func checkBudgetAlert(for newAmount: Double) {
        let currentMonth = Calendar.current.dateInterval(of: .month, for: Date())!
        let totalSpent = expenses.filter { currentMonth.contains($0.date ?? Date()) }.reduce(0) { $0 + $1.amount }
        
        if totalSpent > monthlyBudget {
            // In a real app, you might trigger a local notification here
            print("Budget exceeded!")
        }
    }
    
    // Security Logic
    func authenticate() {
        guard isBiometricEnabled else { return }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your Finance Coach"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAppLocked = false
                    } else {
                        // Handle authentication failure
                        print("Authentication failed")
                    }
                }
            }
        }
    }
}
