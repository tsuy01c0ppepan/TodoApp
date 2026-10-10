import SwiftUI
import SwiftData

enum TodoEditorMode {
    case add
    case edit(TodoItem)

    var navigationTitle: String {
        switch self {
        case .add: "新規TODO"
        case .edit: "TODOを編集"
        }
    }
}

struct TodoEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mode: TodoEditorMode

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var priority: Priority = .normal
    @State private var hasDueDate = false
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var showValidation = false

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("内容") {
                    TextField("タイトル", text: $title)
                        .submitLabel(.next)
                        .accessibilityIdentifier("todo_title_field")

                    TextField("メモ（任意）", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("詳細") {
                    Picker("優先度", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Label(p.label, systemImage: p.systemImage).tag(p)
                        }
                    }

                    Toggle("期限を設定", isOn: $hasDueDate.animation())

                    if hasDueDate {
                        DatePicker(
                            "期限",
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                    }
                }

                if case .edit(let item) = mode {
                    Section {
                        Button {
                            withAnimation {
                                item.toggleCompleted()
                            }
                            dismiss()
                        } label: {
                            Label(
                                item.isCompleted ? "未完了に戻す" : "完了にする",
                                systemImage: item.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle"
                            )
                        }

                        Button(role: .destructive) {
                            modelContext.delete(item)
                            dismiss()
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(mode.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        .disabled(!canSave)
                        .fontWeight(.semibold)
                }
            }
            .onAppear(perform: load)
            .alert("タイトルを入力してね", isPresented: $showValidation) {
                Button("OK", role: .cancel) {}
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func load() {
        guard case .edit(let item) = mode else { return }
        title = item.title
        note = item.note
        priority = item.priority
        if let due = item.dueDate {
            hasDueDate = true
            dueDate = due
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showValidation = true
            return
        }

        let cleanedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let due = hasDueDate ? Calendar.current.startOfDay(for: dueDate) : nil

        switch mode {
        case .add:
            let item = TodoItem(
                title: trimmed,
                note: cleanedNote,
                priority: priority,
                dueDate: due
            )
            modelContext.insert(item)
        case .edit(let item):
            item.title = trimmed
            item.note = cleanedNote
            item.priority = priority
            item.dueDate = due
        }

        dismiss()
    }
}

#Preview("Add") {
    TodoEditorSheet(mode: .add)
        .modelContainer(for: TodoItem.self, inMemory: true)
}
