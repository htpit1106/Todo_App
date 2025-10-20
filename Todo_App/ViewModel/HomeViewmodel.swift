import Foundation
import RxSwift
import RxCocoa

class HomeViewmodel {
    static let shared = HomeViewmodel()
    private init() {}
    
    private let service = TodoService()
    private let disposeBag = DisposeBag()
    
    // MARK: - Outputs
    let todos = BehaviorRelay<[Todo]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishSubject<String>()
    
    var sections: Observable<[(title: String, items: [Todo])]> {
        todos.map { todos in
            let uncompleted = todos.filter { !$0.isCompleted }
            let completed = todos.filter { $0.isCompleted }
            return [
                (title: "", items: uncompleted),
                (title: "Completed", items: completed)
            ]
        }
    }
    
    // MARK: - Actions
    func fetchTodos() {
        isLoading.accept(true)
        Task {
            do {
                let data = try await service.fetchTodos()
                DispatchQueue.main.async {
                    self.todos.accept(data)
                    self.isLoading.accept(false)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading.accept(false)
                    self.errorMessage.onNext("Failed to load todos: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func toggleCompleted(todo: Todo) {
        guard let id = todo.id else { return }
        Task {
            do {
                try await service.updateCompleted(id: id, isCompleted: !todo.isCompleted)
                var list = todos.value
                if let index = list.firstIndex(where: { $0.id == id }) {
                    list[index].isCompleted.toggle()
                    todos.accept(list)
                }
            } catch {
                errorMessage.onNext("Failed to update status: \(error.localizedDescription)")
            }
        }
    }
    
    func addTodo(_ todo: Todo) {
        Task {
            do {
                try await service.addTodo(todo)
                var list = todos.value
                list.append(todo)
                todos.accept(list)
            } catch {
                errorMessage.onNext("Failed to add todo: \(error.localizedDescription)")
            }
        }
    }
}
