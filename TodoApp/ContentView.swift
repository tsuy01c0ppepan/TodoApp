import SwiftUI
import SwiftData

enum TodoFilter: String, CaseIterable, Identifiable {
    case all = "すべて"
    case active = "未完了"
    case completed = "完了"

    var id: String { rawValue }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var todos: [TodoItem]

    @State private var filter: TodoFilter = .all
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var editingItem: TodoItem?

    private var filteredTodos: [TodoItem] {
        todos.filter { item in
            let matchesFilter: Bool = {
                switch filter {
                case .all: true
                case .active: !item.isCompleted
                case .completed: item.isCompleted
                }
            }()

            let matchesSearch: Bool = {
                guard !searchText.isEmpty else { return true }
                let q = searchText.lowercased()
                return item.title.lowercased().contains(q)
                    || item.note.lowercased().contains(q)
            }()

            return matchesFilter && matchesSearch
        }
    }

    private var activeCount: Int {
        todos.filter { !$0.isCompleted }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if todos.isEmpty {
                    emptyState
                } else if filteredTodos.isEmpty {
                    ContentUnavailableView(
                        "該当なし",
                        systemImage: "magnifyingglass",
                        description: Text("条件に合うTODOがありません")
                    )
                } else {
                    todoList
                }
            }
            .navigationTitle("TODO")
            .searchable(text: $searchText, prompt: "タイトル・メモを検索")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !todos.isEmpty {
                        Text("残り \(activeCount)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("未完了 \(activeCount) 件")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("TODOを追加")
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !todos.isEmpty {
                    filterBar
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                TodoEditorSheet(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                TodoEditorSheet(mode: .edit(item))
            }
            .onAppear(perform: seedDemoIfRequested)
        }
    }

    /// Launch with `-seedDemo` to insert sample todos when the store is empty.
    private func seedDemoIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-seedDemo") else { return }
        guard todos.isEmpty else { return }

        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: Date())
        let nextWeek = cal.date(byAdding: .day, value: 7, to: Date())

        let samples = [
            TodoItem(
                title: "牛乳を買う",
                note: "低脂肪・1L",
                priority: .normal,
                dueDate: tomorrow.map { cal.startOfDay(for: $0) }
            ),
            TodoItem(
                title: "週次レビューを書く",
                note: "進捗と来週の優先事項",
                priority: .high,
                dueDate: nextWeek.map { cal.startOfDay(for: $0) }
            ),
            TodoItem(
                title: "コッペパンのレシピを探す",
                note: "強強バージョン",
                priority: .low
            ),
        ]
        samples.forEach { modelContext.insert($0) }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("TODOなし", systemImage: "checklist")
        } description: {
            Text("右上の + から最初のTODOを追加しよう")
        } actions: {
            Button("追加する") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var todoList: some View {
        List {
            ForEach(filteredTodos) { item in
                TodoRowView(item: item) {
                    editingItem = item
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delete(item)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        withAnimation {
                            item.toggleCompleted()
                        }
                    } label: {
                        Label(
                            item.isCompleted ? "未完了に戻す" : "完了",
                            systemImage: item.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle"
                        )
                    }
                    .tint(item.isCompleted ? .orange : .green)
                }
            }
            .onDelete(perform: deleteOffsets)
        }
        .listStyle(.plain)
        .animation(.default, value: filteredTodos.map(\.id))
    }

    private var filterBar: some View {
        Picker("フィルター", selection: $filter) {
            ForEach(TodoFilter.allCases) { f in
                Text(f.rawValue).tag(f)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func delete(_ item: TodoItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }

    private func deleteOffsets(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredTodos[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
