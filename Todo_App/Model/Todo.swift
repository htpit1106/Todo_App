//
//  Todo.swift
//  Todo_App
//
//  Created by Admin on 10/13/25.
//

import Foundation

class Todo: Codable {
    var id: String?
    var title: String?
    var category: String?
    var created_at: Date?
    
    var content: String?
    var isCompleted: Bool = false
    
    init(id: String? = nil, title: String? = nil, category: String? = nil, created_at: Date? = nil, content: String? = nil, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.category = category
        self.created_at = created_at
        self.content = content
        self.isCompleted = isCompleted
    }
    
     func setIsCompleted(_ value: Bool) {
        isCompleted = value
    }
    
 

}

#if DEBUG

extension Todo {
    private static func parseISODate(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withSpaceBetweenDateAndTime]
        return f.date(from: s)
    }
    
    
    static var todolist = [ [
        Todo(id: "1", title: "run 5k", category: "cup", created_at: Todo.parseISODate("2025-10-13 08:04:53.587705+00:00"), content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", isCompleted: false),
        Todo(id: "2", title: "Game meetup", category: "cup", created_at: Todo.parseISODate("2025-10-13 08:04:53.587705+00:00"), content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", isCompleted: false),
        Todo(id: "5", title: "run 5k", category: "cup", created_at: Todo.parseISODate("2025-10-13 08:04:53.587705+00:00"), content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", isCompleted: false),
        Todo(id: "6", title: "Game meetup", category: "cup", created_at: Todo.parseISODate("2025-10-13 08:04:53.587705+00:00"), content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", isCompleted: false),
 
        
        ],
        [Todo(id: "3", title: "Go to party", category: "list", created_at: Todo.parseISODate("2025-10-13 08:04:53.587705+00:00"), content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", isCompleted: true),
        Todo(id: "4", title: "Take out trash", category: "calendar", created_at: Todo.parseISODate("2025-10-13 08:04:53.587705+00:00"), content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", isCompleted: true)]
                                     
    ]
}


#endif



