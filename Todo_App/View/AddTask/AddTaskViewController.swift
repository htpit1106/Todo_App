import RxCocoa
import RxSwift
import UIKit

class AddTaskViewController: UIViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var cupBtn: UIButton!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var notesTV: UITextView!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!

    var todoUpdate: Todo?

    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    private let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()

    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        return f
    }()

    // Rx
    private let disposeBag = DisposeBag()

    // UI state relays
    private let titleRelay = BehaviorRelay<String>(value: "")
    private let notesRelay = BehaviorRelay<String>(value: "")
    private let dateRelay = BehaviorRelay<Date>(value: Date())
    private let timeRelay = BehaviorRelay<Date>(value: Date())
    private let categoryRelay = BehaviorRelay<String>(value: "list")
    let appearance = UINavigationBarAppearance()

    private let viewModel = HomeViewmodel.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // nav bar appearance
        appearance.configureWithOpaqueBackground()
        appearance.backgroundImage = UIImage(named: "header")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white

        notesTV.layer.backgroundColor = UIColor.white.cgColor
        configureCategoryButtons()
        setIconTextField(dateTF, iconName: "calendar")
        setIconTextField(timeTF, iconName: "clock")
        setupPickers()
      
        titleTF.attributedPlaceholder = NSAttributedString(
            string: "Task Title",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray2
            ]
        )

        if let todo = todoUpdate {
            UIUpdateTask(todo: todo)
            print(todo.time)
        } else {
            UIAddTask()
        }

        bindUI()
        bindSave()
    }


    // MARK: - Bindings

    private func bindUI() {
        // Inputs -> Relays
        titleTF.rx.text.orEmpty
            .bind(to: titleRelay)
            .disposed(by: disposeBag)

        notesTV.rx.text.orEmpty
            .bind(to: notesRelay)
            .disposed(by: disposeBag)

        datePicker.rx.date
            .bind(to: dateRelay)
            .disposed(by: disposeBag)

        timePicker.rx.date
            .bind(to: timeRelay)
            .disposed(by: disposeBag)

        // Category button UI updates when relay changes
        categoryRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateCategorySelection()
            })
            .disposed(by: disposeBag)

        // keep date/time text fields in sync with relays
        dateRelay
            .map { [weak self] in self?.dateFormatter.string(from: $0) ?? "" }
            .bind(to: dateTF.rx.text)
            .disposed(by: disposeBag)

        timeRelay
            .map { [weak self] in self?.timeFormatter.string(from: $0) ?? "" }
            .bind(to: timeTF.rx.text)
            .disposed(by: disposeBag)

        
        // Enable save button only when required fields are not empty
//        Observable.combineLatest(titleRelay, notesRelay)
//            .map { title, notes in
//                !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//                    && !notes.trimmingCharacters(in: .whitespacesAndNewlines)
//                        .isEmpty
//            }
//            .distinctUntilChanged()
//            .observe(on: MainScheduler.instance)
//            .bind(to: saveBtn.rx.isHidden)
//            .disposed(by: disposeBag)
    }

    // nut save
    private func bindSave() {
        // on tap -> construct Todo and call ViewModel (add or update)
        saveBtn.rx.tap
            .withLatestFrom(
                Observable.combineLatest(
                    titleRelay,
                    notesRelay,
                    dateRelay,
                    timeRelay,
                    categoryRelay
                )
            )
            .flatMapLatest {
                [weak self] title, notes, datePart, timePart, category
                    -> Observable<Event<Void>> in
                guard let self = self else { return Observable.empty() }

                // combine date + time parts into a single Date
                let cal = Calendar.current
                var dateComp = cal.dateComponents(
                    [.year, .month, .day],
                    from: datePart
                )
                let timeComp = cal.dateComponents(
                    [.hour, .minute],
                    from: timePart
                )
                dateComp.hour = timeComp.hour
                dateComp.minute = timeComp.minute

                guard let combined = cal.date(from: dateComp) else {
                    return Observable.just(Event.error(RxError.unknown))
                }

                let isoString = self.isoFormatter.string(from: combined)

                // khi vao man update
                if var existing = self.todoUpdate {
                    // Update existing todo
                    existing.title = title
                    existing.content = notes
                    existing.time = isoString
                    existing.category = category

                    // Use Rx wrapper updateTodoRx(_:) which returns Completable
                    return self.viewModel.updateTodoRx(existing)
                        .andThen(Observable.just(()))
                        .materialize()
                } else {
                    // Create new Todo — do not force an id here if backend creates it
                    let newTodo = Todo(
                        id: UUID().uuidString,
                        title: title,
                        category: category,
                        created_at: Date(),
                        content: notes,
                        time: isoString,
                        isCompleted: false
                    )

                    return self.viewModel.addTodoRx(newTodo)
                        .andThen(Observable.just(()))
                        .materialize()
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next:
                    // Completed successfully
                    self?.navigationController?.popViewController(
                        animated: true
                    )
                case .error(let e):
                    self?.showAlert(
                        message: "Operation failed: \(e.localizedDescription)"
                    )
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - UI setup for Add / Update

    func UIAddTask() {
        let now = Date()

        datePicker.date = now
        timePicker.date = now

        categoryRelay.accept("list")
    }

    func UIUpdateTask(todo: Todo) {
        titleTF.text = todo.title
        notesTV.text = todo.content
        if todo.isCompleted == true {
            self.title = "Edit Task ✓"
        } else {
            self.title = "Edit Task"
        }

        if let isoString = todo.time, let d = isoFormatter.date(from: isoString)
        {
            
            datePicker.date = d
            timePicker.date = d
        } else {
            // fallback: keep pickers on current date/time or set to now
            let now = Date()
            datePicker.date = now
            timePicker.date = now

        }

        categoryRelay.accept(todo.category ?? "list")
    }

    // MARK: - Pickers, toolbar, helpers

    func setIconTextField(_ textField: UITextField, iconName: String) {
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = UIColor(
            red: 74 / 255.0,
            green: 55 / 255.0,
            blue: 128 / 255.0,
            alpha: 1.0
        )
        icon.contentMode = .scaleAspectFit
        let iconContainer = UIView(
            frame: CGRect(x: 0, y: 0, width: 35, height: 20)
        )
        icon.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        iconContainer.addSubview(icon)
        textField.rightView = iconContainer
        textField.rightViewMode = .always
    }

    private func setupPickers() {

        // ngăn sử dụng phím để nhập
        dateTF.tintColor = .clear  // ẩn con trỏ nháy
        dateTF.autocorrectionType = .no  // tắt gợi ý
        dateTF.spellCheckingType = .no  // tắt kiểm tra chính tả
        dateTF.isUserInteractionEnabled = true  // vẫn tap được

        timeTF.tintColor = .clear
        timeTF.autocorrectionType = .no
        timeTF.spellCheckingType = .no
        timeTF.isUserInteractionEnabled = true

        
        // set style for picker
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) { datePicker.locale = Locale.current }
        datePicker.minimumDate = Calendar.current.startOfDay(for: Date())

        dateTF.inputView = datePicker
        dateTF.inputAccessoryView = makeToolbarPicker(
            doneSelector: #selector(doneDate),
            cancelSelector: #selector(cancelEditing)
        )

        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) { timePicker.locale = Locale.current }

        timeTF.inputView = timePicker
        timeTF.inputAccessoryView = makeToolbarPicker(
            doneSelector: #selector(doneTime),
            cancelSelector: #selector(cancelEditing)
        )
    }

    private func makeToolbarPicker(
        doneSelector: Selector,
        cancelSelector: Selector
    ) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancel = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: cancelSelector
        )
        let flex = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: doneSelector
        )
        toolbar.items = [cancel, flex, done]
        return toolbar
    }

    @objc private func doneDate() {
        dateTF.resignFirstResponder()
    }

    @objc private func doneTime() {
        timeTF.resignFirstResponder()
    }

    @objc private func cancelEditing() {
        view.endEditing(true)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        dateTF.text = dateFormatter.string(from: sender.date)
    }

    @objc private func timeChanged(_ sender: UIDatePicker) {
        timeTF.text = timeFormatter.string(from: sender.date)
    }

    // MARK: - Category buttons

    @IBAction func onListCategory(_ sender: Any) {
        categoryRelay.accept("list")
    }

    @IBAction func onCalendarCategory(_ sender: Any) {
        categoryRelay.accept("calendar")
    }

    @IBAction func onCupCategory(_ sender: Any) {
        categoryRelay.accept("cup")
    }

    private func configureCategoryButtons() {
        [listBtn, calendarBtn, cupBtn].forEach { btn in
            guard let btn = btn else { return }
            var config = btn.configuration ?? .filled()
            config.cornerStyle = .capsule
            config.baseBackgroundColor = .white
            config.baseForegroundColor = .black
            btn.configuration = config
        }
        updateCategorySelection()
    }

    private func updateCategorySelection() {
        func apply(_ button: UIButton?, selected: Bool) {
            guard let button = button else { return }
            var config = button.configuration ?? .filled()
            config.cornerStyle = .capsule
            config.baseBackgroundColor = selected ? .black : .white
            config.baseForegroundColor = selected ? .white : .black
            button.configuration = config
        }
        apply(listBtn, selected: categoryRelay.value == "list")
        apply(calendarBtn, selected: categoryRelay.value == "calendar")
        apply(cupBtn, selected: categoryRelay.value == "cup")
    }

    // MARK: - Helpers

    func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Missing Information",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
