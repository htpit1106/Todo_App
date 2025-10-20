//
//  AddTaskViewmodel.swift
//  Todo_App
//
//  Created by Admin on 10/20/25.
//

import Foundation
import RxCocoa
import RxSwift

class AddTaskViewModel {

    // Inputs
    let title = BehaviorRelay<String>(value: "")
    let notes = BehaviorRelay<String>(value: "")
    let category = BehaviorRelay<String>(value: "list")
    let date = BehaviorRelay<Date>(value: Date())
    let time = BehaviorRelay<Date>(value: Date())
    let saveTap = PublishRelay<Void>()

    let errorMessage = PublishRelay<String>()
    let taskSaved = PublishRelay<Void>()

    private let viewModel = HomeViewmodel.shared
    private let disposeBag = DisposeBag()

    init(existingTodo: Todo? = nil) {
        // Nếu update task, init các BehaviorRelay với giá trị cũ
        if let todo = existingTodo {
            title.accept(todo.title ?? "")
            notes.accept(todo.content ?? "")
            category.accept(todo.category ?? "list")
            if let iso = todo.time,
                let dt = ISO8601DateFormatter().date(from: iso)
            {
                date.accept(dt)
                time.accept(dt)
            }
        }

        saveTap
            .withLatestFrom(
                Observable.combineLatest(title, notes, category, date, time)
            )
            .subscribe(onNext: {
                [weak self] title, notes, category, date, time in
                self?.handleSave(
                    title: title,
                    notes: notes,
                    category: category,
                    date: date,
                    time: time,
                    existingTodo: existingTodo
                )
            })
            .disposed(by: disposeBag)

    }
    
    
    private func handleSave(title: String, notes: String, category: String, date: Date, time: Date, existingTodo: Todo?) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage.accept("Please enter a task title.")
            return
        }
        guard !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage.accept("Please enter notes.")
            return
        }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second

        guard let combinedDate = calendar.date(from: components) else { return }

        let isoString = ISO8601DateFormatter().string(from: combinedDate)

        if let todo = existingTodo {
            todo.title = title
            todo.content = notes
            todo.category = category
            todo.time = isoString
            Task {
                await MainActor.run {
                    self.taskSaved.accept(())
                }
            }
        } else {
            let newTodo = Todo(
                id: UUID().uuidString,
                title: title,
                category: category,
                created_at: Date(),
                content: notes,
                time: isoString,
                isCompleted: false
            )
            Task {
                await viewModel.addTodo(newTodo)
                await MainActor.run {
                    self.taskSaved.accept(())
                }
            }
        }
    }
    

}
