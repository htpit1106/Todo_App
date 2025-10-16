//
//  SupabaseService.swift
//  Todo_App
//
//  Created by Admin on 10/16/25.
//

import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    private init(){}
    
    private let supabase = SupabaseClient(
        supabaseURL: SupabaseConfig.url, supabaseKey: SupabaseConfig.key
    )
    
    
    func fetchTodos () async throws -> [Todo] {
        try await supabase
            .from("todo_list")
            .select()
            .order("created_at", ascending:  false)
            .execute()
            .value
    }
    
    func addTodo(_ todo: Todo) async throws {
        // Prefer inserting an Encodable model instead of a [String: Any?] dictionary to satisfy Encodable constraints.
        // Ensure your `Todo` type conforms to `Encodable`.
        try await supabase
            .from("todo_list")
            .insert(todo)
            .execute()
    }
    
    
    
}

