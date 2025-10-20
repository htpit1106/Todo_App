import Foundation
import Supabase

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init<T: Encodable>(_ wrapped: T) {
        self._encode = wrapped.encode(to:)
    }
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

class TodoService {
    private let client = supabase

    func fetchTodos() async throws -> [Todo] {
        try await client
            .from("todo_list")
            .select("*")
            .execute()
            .value
    }

    func addTodo(_ todo: Todo) async throws {
        try await client.from("todo_list").insert(todo).execute()
    }
    
    func updateCompleted(id: String, isCompleted: Bool) async throws {
        try await client
            .from("todo_list")
            .update(["isCompleted": isCompleted])
            .eq("id", value: id)
            .execute()
    }
    
    func deleteTodo(id: String) async throws {
        try await client
            .from("todo_list")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    func updateTodo(_ todo: Todo) async throws {
        var updateData: [String: AnyEncodable] = [:]
        if let title = todo.title { updateData["title"] = AnyEncodable(title) }
        if let content = todo.content { updateData["content"] = AnyEncodable(content) }
        if let category = todo.category { updateData["category"] = AnyEncodable(category) }
        if let time = todo.time { updateData["time"] = AnyEncodable(time) }
        
        try await client
            .from("todo_list")
            .update(updateData)
            .eq("id", value: todo.id)
            .execute()
    }
}
