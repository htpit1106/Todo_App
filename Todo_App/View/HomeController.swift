import UIKit
import RxSwift
import RxCocoa
import RxDataSources

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

        todoTableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.05)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    
    private func setupTableView() {
        let nib = UINib(nibName: "TodoItemView", bundle: nil)
        todoTableView.register(nib, forCellReuseIdentifier: "TodoItemView")
        todoTableView.rowHeight = 70
        todoTableView.separatorStyle = .singleLine    }
    
    private func bindTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Todo>>(
            configureCell: { [weak self] ds, tv, indexPath, todo in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "TodoItemView", for: indexPath) as? TodoItemView else {
                    return UITableViewCell()
                }
                cell.configView(todo: todo)
                cell.onCheckBtn = {
                    self?.viewModel.toggleCompleted(todo: todo)
                }
                return cell
            },
            titleForHeaderInSection: { ds, index in
                ds.sectionModels[index].model
            }
        )
        
        viewModel.sections
            .map { sections in
                sections.map { SectionModel(model: $0.title, items: $0.items) }
            }
            .bind(to: todoTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func bindEvents() {
        // Khi nhấn nút + để thêm task mới
        addTaskBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                print("Navigate to Add Task screen")
                if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "AddTaskViewController") {
                    self?.navigationController?.pushViewController(vc, animated: true)
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
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
