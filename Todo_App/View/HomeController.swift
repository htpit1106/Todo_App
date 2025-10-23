import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class HomeController: UIViewController {
    @IBOutlet weak var titleAppLB: UILabel!
    @IBOutlet weak var todayLb: UILabel!
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var addTaskBtn: UIButton!

    private let disposeBag = DisposeBag()
    private var viewModel = HomeViewmodel.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindTableView()
        bindEvents()

        // Load dữ liệu từ Supabase
        viewModel.fetchTodos()
    }

    private func bindTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<
            SectionModel<String, Todo>
        >(
            
            configureCell: { [weak self] ds, tv, indexPath, todo in
                guard
                    let cell = tv.dequeueReusableCell(
                        withIdentifier: "TodoItemView",
                        for: indexPath
                    ) as? TodoItemView
                else {
                    return UITableViewCell()
                }
                cell.configView(todo: todo)
                
                cell.layer.cornerRadius = 8
                cell.onCheckBtn = {
                    self?.viewModel.toggleCompleted(todo: todo)
                }
                return cell
            },
            titleForHeaderInSection: { ds, index in
                ds.sectionModels[index].model
            }
        )
        
        // bind todotable voi observable section
        viewModel.sections
            .observe(on: MainScheduler.instance)
            .bind(to: todoTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
    }

    private func bindEvents() {
        // Khi nhấn nút + để thêm task mới

        // rx.tap: la 1 observable cua uibutton
        addTaskBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                print("Navigate to Add Task screen")
                if let vc = self?.storyboard?.instantiateViewController(
                    withIdentifier: "AddTaskViewController"
                ) {
                    self?.navigationController?.pushViewController(
                        vc,
                        animated: true
                    )
                }
            })
            .disposed(by: disposeBag)

        // click cell to move updateViewController
        todoTableView.rx.modelSelected(Todo.self)
            .subscribe(onNext: { [weak self] todo in
                guard let self = self else { return }
                if todo.isCompleted { return }
                if let vc = self.storyboard?.instantiateViewController(
                    withIdentifier: "AddTaskViewController"
                ) as? AddTaskViewController {
                    vc.todoUpdate = todo
                    self.navigationController?.pushViewController(
                        vc,
                        animated: true
                    )

                }
            })

        todoTableView.rx.modelDeleted(Todo.self)
            .subscribe(onNext: { [weak self] todo in
                guard let self = self else { return }
                
                Task {
                    do {
                        try await self.viewModel.deleteTodo(todo)
                        // Cập nhật local list
                        var list = self.viewModel.todos.value
                        list.removeAll { $0.id == todo.id }
                        self.viewModel.todos.accept(list)
                    } catch {
                        self.viewModel.errorMessage.onNext(
                            "Failed to delete: \(error.localizedDescription)"
                        )
                    }
                }
            })
            .disposed(by: disposeBag)

        // Quan sát lỗi
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert(message: msg)
            })
            .disposed(by: disposeBag)

    }

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        todoTableView.layer.cornerRadius = 16
        todoTableView.backgroundColor = .clear
        titleAppLB.font = UIFont.boldSystemFont(ofSize: 30)

        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM dd, yyyy"
        todayLb.text = formatter.string(from: now)

        todoTableView.separatorColor = UIColor.lightGray.withAlphaComponent(
            0.05
        )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    private func setupTableView() {
        let nib = UINib(nibName: "TodoItemView", bundle: nil)
        todoTableView.register(nib, forCellReuseIdentifier: "TodoItemView")
        todoTableView.rowHeight = 70
        todoTableView.separatorStyle = .singleLine
        todoTableView.delegate = self
    }

}


extension HomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        
        let title = header.textLabel?.text ?? ""
        
        header.textLabel?.textColor = .black

    }
}
