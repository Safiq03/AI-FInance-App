import Foundation

struct CategorizationService {
    static let shared = CategorizationService()
    
    private let keywordMap: [Category: [String]] = [
        .food: ["pizza", "burger", "coffee", "restaurant", "starbucks", "mcdonalds", "grocery", "food", "dinner", "lunch"],
        .travel: ["uber", "lyft", "flight", "hotel", "bus", "train", "taxi", "gas", "fuel", "airbnb"],
        .bills: ["rent", "electricity", "water", "internet", "phone", "insurance", "subscription", "netflix", "icloud"],
        .shopping: ["amazon", "clothes", "shoes", "target", "walmart", "apple", "mall", "buying"]
    ]
    
    func suggestCategory(for notes: String) -> Category {
        let lowercaseNotes = notes.lowercased()
        
        for (category, keywords) in keywordMap {
            for keyword in keywords {
                if lowercaseNotes.contains(keyword) {
                    return category
                }
            }
        }
        
        return .others
    }
}
