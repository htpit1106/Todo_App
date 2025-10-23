//
//  Todo.swift
//  Todo_App
//
//  Created by Admin on 10/13/25.
//

import Foundation

class Todo: Codable, Identifiable {
    var id: String?
    var title: String?
    var category: String?
    var created_at: Date?
    var content: String?
    var time: String?
    var isCompleted: Bool = false
    var user_id: String?
    
    
    init(id: String? = nil, title: String? = nil, category: String? = nil, created_at: Date? = nil, content: String? = nil, time: String? ,  isCompleted: Bool) {
        self.id = id
        self.title = title
        self.category = category
        self.created_at = created_at
        self.content = content
        self.isCompleted = isCompleted
        self.time = time
    }
    
     func setIsCompleted(_ value: Bool) {
        isCompleted = value
    }
    
 

}





