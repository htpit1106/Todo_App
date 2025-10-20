//
//  Superbase.swift
//  Todo_App
//
//  Created by Admin on 10/13/25.
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://kcnaulmfjtjlnhimzktp.supabase.co")!
    static let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtjbmF1bG1manRqbG5oaW16a3RwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyOTIzNjIsImV4cCI6MjA3NTg2ODM2Mn0.aZKERIl9WRS5OyBxZcwLcuUz75GIwP2uHUGfdO3jG9g"
    
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.key
)
