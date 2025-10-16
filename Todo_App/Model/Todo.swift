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
    var created_at: String?
    var content: String?
    var time: String?
    var isCompleted: Bool = false
    
    
    init(id: String? = nil, title: String? = nil, category: String? = nil, created_at: String? = nil, content: String? = nil, time: String? ,  isCompleted: Bool) {
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

#if DEBUG

extension Todo {
    
    
    static var todolist = [ [
        Todo(id: "1", title: "run 5k", category: "cup", created_at: "2025-10-13 08:04:53.587705+00:00" , content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", time: "2025-10-13 08:04:53.587705+00:00",  isCompleted: false),
        Todo(id: "2", title: "Game meetup", category: "cup", created_at: "2025-10-13 08:04:53.587705+00:00", content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", time: "2025-10-13 08:04:53.587705+00:00", isCompleted: false),
        Todo(id: "5", title: "run 5k", category: "cup", created_at: "2025-10-13 08:04:53.587705+00:00", content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", time: "2025-10-13 08:04:53.587705+00:00", isCompleted: false),
        Todo(id: "6", title: "Game meetup", category: "cup", created_at:"2025-10-13 08:04:53.587705+00:00", content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)",time: "2025-10-13 08:04:53.587705+00:00",  isCompleted: false),
 
        
        ],
        [Todo(id: "3", title: "Go to party", category: "list", created_at: "2025-10-13 08:04:53.587705+00:00", content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", time: "2025-10-13 08:04:53.587705+00:00", isCompleted: true),
        Todo(id: "4", title: "Take out trash", category: "calendar", created_at:"2025-10-13 08:04:53.587705+00:00", content: "tạo luôn file TodoCell.xib (có layout code và ví dụ chạy hoàn chỉnh)", time: "2025-10-13 08:04:53.587705+00:00", isCompleted: true)]
                                     
    ]
    
    
}


#endif



