//
//  TodoViewModel.swift
//  Todo_App
//
//  Created by Admin on 10/16/25.
//

import Foundation
import Combine

@MainActor
final class HomeViewmodel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = SupabaseService.shared

    func loadTodos() async {
        isLoading = true
        defer { isLoading = false }

        do {
            todos = try await service.fetchTodos()
            
            print(todos.count)
        } catch {
            errorMessage = "Không thể tải danh sách công việc"
            print("❌ Fetch error:", error)
        }
    }

    func addTodo(_ todo: Todo) async {
        do {
            try await service.addTodo(todo)
            await loadTodos()
        } catch {
            errorMessage = "Không thể thêm công việc"
            print("❌ Add error:", error)
        }
    }

//    func toggleComplete(todo: Todo) async {
//        do {
//            try await service.updateTodoCompletion(
//                id: todo.id,
//                isCompleted: !todo.isCompleted
//            )
//            await loadTodos()
//        } catch {
//            errorMessage = "Không thể cập nhật trạng thái"
//        }
//    }
//
//    func deleteTodo(id: String) async {
//        do {
//            try await service.deleteTodo(id: id)
//            await loadTodos()
//        } catch {
//            errorMessage = "Không thể xóa công việc"
//        }
//    }
}
