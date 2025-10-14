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

    var listTodo = Todo.todolist
    var headerTitle = ["", "Completed"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.tintColor = .white
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
        
        
        
        todoTableView.dataSource = self
        todoTableView.delegate = self

    }
    
    @IBAction func onPressAddTask(_ sender: Any) {
        print("pressed")
//        if let addView = storyboard?.instantiateViewController(withIdentifier: "AddNewTaskView")
//            as? AddNewTaskViewController {
//            navigationController?.pushViewController(addView, animated: true)
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return listTodo[section].count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return listTodo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let todo = listTodo[indexPath.section][indexPath.row]
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "TodoItemView"
        ) as? TodoItemView {

            cell.configView(todo: todo)
            
            
            
            cell.onCheckBtn = {
                [weak self] in
                guard let self = self else { return }

                todo.setIsCompleted(!todo.isCompleted)

                if indexPath.section == 0 {
                    listTodo[0].remove(at: indexPath.row)
                    listTodo[1].append(todo)

                }
                todoTableView.reloadData()

            }
            return cell

        } else {
            return TodoItemView()
        }

    }

    // header

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
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
//        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 16
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 80
    }

}
