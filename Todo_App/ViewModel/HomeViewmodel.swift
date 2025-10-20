import Foundation

import Combine
@MainActor
class HomeViewmodel: ObservableObject {
    
    static let shared = HomeViewmodel()
    private init() {}
    
    @Published var todos: [[Todo]] = [[], []]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = TodoService()

    func loadTodos() async {
        isLoading = true
        defer { isLoading = false }

        do {
            todos = try await service.fetchTodos()
        } catch {
            errorMessage = "Không thể tải danh sách công việc"
            print("Lỗi fetch:", error)
        }
    }

    func addTodo(_ todo: Todo) async {
        do {
            try await service.addTodo(todo)
            await loadTodos() // load lại để cập nhật UI
        } catch {
            print("Loi them task", error)
        }
    }
    
    
    @MainActor
    func toggleCompleted(for todo: Todo) async {
        do {
            guard let id = todo.id else {
                return
            }
            try await service.updateCompleted(id: id,  isCompleted: !todo.isCompleted)
     
        } catch {
            print("Lỗi cập nhật trạng thái:", error)
        }
    }
    
    @MainActor
    func deleteTodo(_ todo: Todo) async {
        
        do {
            guard let id = todo.id else {
                return
            }
            try await service.deleteTodo(id: id)
            
            
        } catch {
            print("loi khi xoa: ", error)
        }
    }
    
    @MainActor
    
    func updateTodo (_ todo: Todo) async {
        do {
            try await service.updateTodo(todo)
            await loadTodos()
            
        } catch {
            print("loi update", error)
        }
    }

}
