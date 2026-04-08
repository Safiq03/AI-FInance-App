import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for preview
        let categories = ["Food", "Travel", "Bills", "Shopping", "Others"]
        let currentMonth = Calendar.current.dateInterval(of: .month, for: Date())!
        
        for i in 0..<10 {
            let newItem = Expense(context: viewContext)
            newItem.id = UUID()
            newItem.amount = Double.random(in: 10...100)
            if i < 7 {
                // Current month expenses
                newItem.date = Date().addingTimeInterval(TimeInterval(-86400 * i))
            } else {
                // Last month expenses
                newItem.date = Date().addingTimeInterval(TimeInterval(-86400 * 40))
            }
            newItem.category = categories.randomElement() ?? "Others"
            newItem.notes = "Sample expense \(i)"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AIFinanceCoach")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
