import SwiftUI
import SwiftData

struct TodoRowView: View {
    @Bindable var item: TodoItem
    var onEdit: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                withAnimation(.snappy) {
                    item.toggleCompleted()
                }
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isCompleted ? Color.green : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isCompleted ? "完了済み。タップで未完了に戻す" : "未完了。タップで完了")

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(item.title)
                        .font(.body.weight(.medium))
                        .strikethrough(item.isCompleted, color: .secondary)
                        .foregroundStyle(item.isCompleted ? .secondary : .primary)
                        .multilineTextAlignment(.leading)

                    if item.priority != .normal {
                        Image(systemName: item.priority.systemImage)
                            .font(.caption)
                            .foregroundStyle(priorityColor)
                            .accessibilityLabel("優先度 \(item.priority.label)")
                    }
                }

                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if let due = item.dueDate {
                    Label(due.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(dueColor(for: due))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: onEdit)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var priorityColor: Color {
        switch item.priority {
        case .low: .blue
        case .normal: .secondary
        case .high: .orange
        }
    }

    private func dueColor(for date: Date) -> Color {
        if item.isCompleted { return .secondary }
        let cal = Calendar.current
        if cal.isDateInToday(date) { return .orange }
        if date < cal.startOfDay(for: Date()) { return .red }
        return .secondary
    }
}

#Preview {
    List {
        TodoRowView(
            item: TodoItem(title: "サンプル", note: "メモあり", priority: .high, dueDate: Date()),
            onEdit: {}
        )
        TodoRowView(
            item: TodoItem(title: "完了済み", isCompleted: true),
            onEdit: {}
        )
    }
}
