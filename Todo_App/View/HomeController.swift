//
//  ViewController.swift
//  Todo_App
//
//  Created by Admin on 10/13/25.
//

import UIKit
import Combine



class HomeController: UIViewController, UITableViewDataSource,
    UITableViewDelegate
{

    @IBOutlet weak var titleAppLB: UILabel!
    @IBOutlet weak var todayLb: UILabel!
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var addTaskBtn: UIButton!

    var headerTitle = ["", "Completed"]
    var cancellabes = Set<AnyCancellable> ()
    private var viewModel = HomeViewmodel.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        EditUI()

        todoTableView.dataSource = self
        todoTableView.delegate = self

        Task {
            await viewModel.loadTodos()
            todoTableView.reloadData()
        }

        viewModel.$todos
                    .receive(on: RunLoop.main)
                    .sink { [weak self] _ in
                        self?.todoTableView.reloadData()
                    }
                    .store(in: &Cancellables)


    }

    @IBAction func onPressAddTask(_ sender: Any) {

        print("press")
        if let addView = storyboard?.instantiateViewController(
            withIdentifier: "AddTaskViewController"
        )
            as? AddTaskViewController
        {
            navigationController?.pushViewController(addView, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return viewModel.todos[section].count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let todo = viewModel.todos[indexPath.section][indexPath.row]
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "TodoItemView"
        ) as? TodoItemView {

            cell.configView(todo: todo)

            cell.onCheckBtn = {
                [weak self] in
                guard let self = self else { return }

                Task {
                    await self.viewModel.toggleCompleted(for: todo)
                    await self.viewModel.loadTodos()
                    self.todoTableView.reloadData()

                }

            }

            return cell

        } else {
            return TodoItemView()
        }

    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let todo = viewModel.todos[indexPath.section][indexPath.row]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: nil
        ) { [weak self] _, _, completion in
            guard let self = self else { return }

            Task {
                await self.viewModel.deleteTodo(todo)

                await MainActor.run {
                    self.viewModel.todos[indexPath.section].remove(
                        at: indexPath.row
                    )
                    self.todoTableView.deleteRows(
                        at: [indexPath],
                        with: .automatic
                    )
                }
            }

            completion(true)
        }

        //
        deleteAction.backgroundColor = UIColor.black
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(
            .white,
            renderingMode: .alwaysOriginal
        )

        // tao editAction neu task chua hoan thanh
        if !todo.isCompleted {
            let editAction = UIContextualAction(style: .normal, title: nil) {
                [weak self] _, _, completion in
                guard let self = self else { return }

                // chuyen sang Trang update
                if let updateView = storyboard?.instantiateViewController(
                    withIdentifier: "AddTaskViewController"
                )
                    as? AddTaskViewController
                {

                    updateView.todoUpdate = todo
                    navigationController?.pushViewController(
                        updateView,
                        animated: true
                    )
                }

            }
            editAction.backgroundColor = UIColor.black
            editAction.image = UIImage(systemName: "pencil.tip")?.withTintColor(
                .white,
                renderingMode: .alwaysOriginal
            )
            return UISwipeActionsConfiguration(actions: [
                deleteAction, editAction,
            ])

        }

        return UISwipeActionsConfiguration(actions: [deleteAction])

    }

    // header cua tung section
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        if viewModel.todos[section].isEmpty {
            return nil
        }
        if section < headerTitle.count {
            return headerTitle[section]
        }
        return nil
    }

    // style heder
    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        if let header = view as? UITableViewHeaderFooterView {
            if viewModel.todos[0].count == 0 {
                header.textLabel?.textColor = UIColor.white
            } else {
                header.textLabel?.textColor = UIColor.black
            }

        }
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cell.layer.cornerRadius = 10
    }

    // sẽ được chạy khi quay lại trang cũ
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reload lai khi save
        Task {
            await viewModel.loadTodos()
            todoTableView.reloadData()
        }
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 70
    }

    func EditUI() {
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true

        todoTableView.layer.cornerRadius = 16
        todoTableView.backgroundColor = .clear

        titleAppLB.font = UIFont.boldSystemFont(ofSize: 30)
        let nib = UINib(nibName: "TodoItemView", bundle: nil)
        todoTableView.register(nib, forCellReuseIdentifier: "TodoItemView")

        // todayLB
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM, dd yyyy"
        todayLb.text = formatter.string(from: now)

        // lam mờ separator line của tableview
        todoTableView.separatorColor = UIColor.lightGray.withAlphaComponent(
            0.05
        )

    }

}
