import Foundation
import RxCocoa
import RxSwift
import RxDataSources
class HomeViewmodel {
    static let shared = HomeViewmodel()
    private init() {}

    private let service = TodoService()
    private let disposeBag = DisposeBag()

    // MARK: - Outputs
    let todos = BehaviorRelay<[Todo]>(value: [])
    let errorMessage = PublishSubject<String>()

    var sections: Observable<[SectionModel<String, Todo>]> {
        todos.map { todos in
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            let calendar = Calendar.current
            let now = Date()
            
            // Chia todo ra
            let uncompleted = todos.filter { !$0.isCompleted }
            let completed = todos.filter { $0.isCompleted }
            
            // Gom nhóm các todo chưa hoàn thành theo thời gian
            let grouped = Dictionary(grouping: uncompleted) { todo -> String in
                guard
                    let iso = todo.time,
                    let date = isoFormatter.date(from: iso)
                else {
                    return "No Date"
                }
                
                if date < now {
                    return "Overdue"
                }
                if calendar.isDateInToday(date) { return "Today" }
                if calendar.isDateInTomorrow(date) { return "Tomorrow" }
                
                if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
                    return "This week"
                }
                if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: now),
                   calendar.isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear) {
                    return "Next week"
                }
                
                return "Later"
            }
            
            //  Thứ tự section mong muốn
            let order = ["Overdue", "Today", "Tomorrow", "This week", "Next week", "Later", "No Date"]
            
            // Tạo danh sách section từ group trên
            var sections: [SectionModel<String, Todo>] = []
            
            for title in order {
                if let items = grouped[title], !items.isEmpty {
                    let sortedItems = items.sorted {
                        guard let d1 = isoFormatter.date(from: $0.time ?? ""),
                              let d2 = isoFormatter.date(from: $1.time ?? "")
                        else { return false }
                        return d1 < d2
                    }
                    sections.append(SectionModel(model: title, items: sortedItems))
                }
            }
            
            // Thêm phần Completed riêng
            if !completed.isEmpty {
                sections.append(SectionModel(model: "Completed", items: completed))
            }
            
            return sections
        }
    }


    // MARK: - Actions
    func fetchTodos() {
        Task {
            do {
                let data = try await service.fetchTodos()
                DispatchQueue.main.async {
                    self.todos.accept(data)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage.onNext(
                        "Failed to load todos: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    func toggleCompleted(todo: Todo) {
        guard let id = todo.id else { return }
        Task {
            do {
                try await service.updateCompleted(
                    id: id,
                    isCompleted: !todo.isCompleted
                )
                var list = todos.value
                if let index = list.firstIndex(where: { $0.id == id }) {
                    list[index].isCompleted.toggle()
                    todos.accept(list)
                }
            } catch {
                errorMessage.onNext(
                    "Failed to update status: \(error.localizedDescription)"
                )
            }
        }
    }

    func addTodoRx(_ todo: Todo) -> Completable {
        Completable.create { completable in
            Task {
                do {
                    try await self.service.addTodo(todo)
                    var list = self.todos.value
                    list.append(todo)
                    self.todos.accept(list)
                    completable(.completed)
                } catch {
                    self.errorMessage.onNext(
                        "Failed to add todo: \(error.localizedDescription)"
                    )
                    completable(.error(error))
                }
            }
            return Disposables.create()
        }
    }

    func updateTodoRx(_ todo: Todo) -> Completable {
        Completable.create { completable in
            Task {
                do {
                    try await self.service.updateTodo(todo)
                    var list = self.todos.value
                    if let index = list.firstIndex(where: { $0.id == todo.id })
                    {
                        list[index] = todo
                        self.todos.accept(list)
                    }
                    completable(.completed)
                } catch {
                    self.errorMessage.onNext(
                        "Failed to update todo: \(error.localizedDescription)"
                    )
                    completable(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    
    func deleteTodo (_ todo: Todo) {
        guard let id = todo.id else {
            return
        }
        
        Task {
            do {
                try await service.deleteTodo(id: id)
                var list = todos.value
                list.removeAll() { $0.id == id }
                self.todos.accept(list)
            } catch {
                errorMessage.onNext("Fail to delete \(error.localizedDescription)")
            }
        }
    }

}
