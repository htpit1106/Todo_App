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
    static let key =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtjbmF1bG1manRqbG5oaW16a3RwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyOTIzNjIsImV4cCI6MjA3NTg2ODM2Mn0.aZKERIl9WRS5OyBxZcwLcuUz75GIwP2uHUGfdO3jG9g"
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.key
)

// MARK: - Đăng nhập ẩn danh lần đầu
func signInAnonymously() async {
    do {
        let session = try await supabase.auth.signInAnonymously()
        print(" Anonymous user created:", session.user.id)

        // Lưu session lại để khôi phục sau
        let accessToken = session.accessToken
        let refreshToken = session.refreshToken
        UserDefaults.standard.set(accessToken, forKey: "access_token")
        UserDefaults.standard.set(refreshToken, forKey: "refresh_token")

    } catch {
        print("Error signing in anonymously:", error)
    }
}

// MARK: - Khôi phục session cũ (nếu có)
func restoreSessionIfNeeded() async {
    if let accessToken = UserDefaults.standard.string(forKey: "access_token"),
        let refreshToken = UserDefaults.standard.string(forKey: "refresh_token")
    {
        do {
            let session = try await supabase.auth.setSession(
                accessToken: accessToken,
                refreshToken: refreshToken
            )
            print("Restored existing session:", session.user.id)
        } catch {
            print("Failed to restore session:", error)
            await signInAnonymously()
        }
    } else {
        // Nếu chưa có session → tạo mới
        await signInAnonymously()
    }
}

// MARK: - Lấy user hiện tại
func getCurrentUser() async -> User? {
    do {
        return try await supabase.auth.session.user
    } catch {
        print("No active session:", error)
        return nil
    }
}
