import SwiftUI

enum Category: String, CaseIterable, Identifiable {
    case food = "Food"
    case travel = "Travel"
    case bills = "Bills"
    case shopping = "Shopping"
    case others = "Others"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .travel: return "airplane"
        case .bills: return "doc.text.fill"
        case .shopping: return "cart.fill"
        case .others: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .travel: return .blue
        case .bills: return .red
        case .shopping: return .purple
        case .others: return .gray
        }
    }
}
