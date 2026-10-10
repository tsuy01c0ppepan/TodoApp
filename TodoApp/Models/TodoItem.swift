import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var note: String
    var isCompleted: Bool
    var priority: Priority
    var createdAt: Date
    var completedAt: Date?
    var dueDate: Date?

    init(
        title: String,
        note: String = "",
        isCompleted: Bool = false,
        priority: Priority = .normal,
        dueDate: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = Date()
        self.completedAt = isCompleted ? Date() : nil
        self.dueDate = dueDate
    }

    func toggleCompleted() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

enum Priority: Int, Codable, CaseIterable, Identifiable {
    case low = 0
    case normal = 1
    case high = 2

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .low: "低"
        case .normal: "普通"
        case .high: "高"
        }
    }

    var systemImage: String {
        switch self {
        case .low: "arrow.down.circle"
        case .normal: "minus.circle"
        case .high: "exclamationmark.circle"
        }
    }

    var tint: String {
        switch self {
        case .low: "blue"
        case .normal: "gray"
        case .high: "orange"
        }
    }
}
