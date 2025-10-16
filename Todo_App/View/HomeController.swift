//
//  ViewController.swift
//  Todo_App
//
//  Created by Admin on 10/13/25.
//

import UIKit

class HomeController: UIViewController, UITableViewDataSource,
    UITableViewDelegate
{

    @IBOutlet weak var titleAppLB: UILabel!
    @IBOutlet weak var todayLb: UILabel!
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var addTaskBtn: UIButton!

    var headerTitle = ["", "Completed"]
    
    private var viewModel = HomeViewmodel()
    override func viewDidLoad() {
        super.viewDidLoad()
        EditUI()


      
        todoTableView.dataSource = self
        todoTableView.delegate = self

        Task {
            await viewModel.loadTodos()

        }
    }


    @IBAction func onPressAddTask(_ sender: Any) {

        print("press")
        if let addView = storyboard?.instantiateViewController(
            withIdentifier: "AddTaskViewController"
        )
            as? AddTaskViewController
        {

            addView.onSaveTask = { [weak self] newTask in
                guard let self = self else { return }
                Todo.todolist[0].append(newTask)
                print(newTask.time)

            }

            navigationController?.pushViewController(addView, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return Todo.todolist[section].count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Todo.todolist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let todo = Todo.todolist[indexPath.section][indexPath.row]
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "TodoItemView"
        ) as? TodoItemView {

            cell.configView(todo: todo)

            cell.onCheckBtn = {
                [weak self] in
                guard let self = self else { return }

                todo.setIsCompleted(!todo.isCompleted)

                if indexPath.section == 0 {
                    Todo.todolist[0].remove(at: indexPath.row)
                    Todo.todolist[1].append(todo)

                } else {
                    Todo.todolist[1].remove(at: indexPath.row)
                    Todo.todolist[0].append(todo)
                }

                todoTableView.reloadData()

            }
            return cell

        } else {
            return TodoItemView()
        }

    }
    
    func EditUI (){
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

    // header

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        if Todo.todolist[section].isEmpty {
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
            header.textLabel?.textColor = UIColor.black
        }
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cell.layer.cornerRadius = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reload lai khi save
        self.todoTableView.reloadData()
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

}
