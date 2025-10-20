//
//  AddTaskViewController.swift
//  Todo_App
//
//  Created by Admin on 10/14/25.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var cupBtn: UIButton!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var notesTV: UITextView!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    
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

    var category: String!

    var viewModel = HomeViewmodel.shared
    override func viewDidLoad() {
        super.viewDidLoad()

        // nav bar - change backgroundImage
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundImage = UIImage(named: "header")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white

        // UI
        notesTV.layer.backgroundColor = UIColor.white.cgColor
        configureCategoryButtons()
        setIconTextField(dateTF, iconName: "calendar")
        setIconTextField(timeTF, iconName: "clock")
        setupPickers()

       
        // color placeholder
        titleTF.attributedPlaceholder = NSAttributedString(
            string: "Task Title",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray2
            ]
        )
        
        if let todo = todoUpdate {
            UIUpdateTask(todo: todo)
        } else {
            UIAddTask()
        }

    }
    
    // ui add view
    
    func UIAddTask() {
        let now = Date()
        dateTF.text = dateFormatter.string(from: now)
        timeTF.text = timeFormatter.string(from: now)
        category = "list"

    }
    
    
    // func UI update task
    
    func UIUpdateTask (todo :Todo) {
        titleTF.text = todo.title
        // Parse the stored ISO8601 string back to Date, then format for display
        if let isoString = todo.time,
            let date = isoFormatter.date(from: isoString) {
            timeTF.text = timeFormatter.string(from: date)
            dateTF.text = dateFormatter.string(from: date)
        }
        notesTV.text = todo.content
        
        
        category = todo.category ?? "list"
            updateCategorySelection()
        
    }
    

    // btn save
    @IBAction func onPressSaveBtn(_ sender: Any) {
    
        let pickedDate = datePicker.date
        let pickedTime = timePicker.date

 
        guard let combined = combine(date: pickedDate, time: pickedTime) else {
            return
        }
        // Format date to  ISO 8601 (string)
        // times = date + time
        let times = isoFormatter.string(from: combined)
        
        let content = notesTV.text
      
        // validate
        guard let title = titleTF.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
                showAlert(message: "Please enter a task title.")
                return
            }

            let notes = notesTV.text ?? ""
            if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                showAlert(message: "Please enter some notes.")
                return
            }
        
        
        if let todo = todoUpdate {
            todo.title = title
            todo.time = times
            todo.content = content
            todo.category = category
//            
            Task {
//                await viewModel.updateTodo(todo)
                await MainActor.run {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            
            
            
        } else {
            // add new task

            let newTask = Todo(
                id: UUID().uuidString,
                title: title,
                category: category,
                created_at: Date(),
                content: content,
                time: times,
                isCompleted: false
            )
            
            Task {
                await viewModel.addTodo(newTask)
                await MainActor.run {
                    self.navigationController?.popViewController(animated: true)
                }
            }

        }
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Missing Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


    // combine date and time from timeTF and dateTF
    
    private func combine(date: Date, time: Date) -> Date? {
        let cal = Calendar.current
        let dateComponents = cal.dateComponents(
            [.year, .month, .day],
            from: date
        )
        let timeComponents = cal.dateComponents(
            [.hour, .minute, .second],
            from: time
        )

        var merged = DateComponents()
        merged.year = dateComponents.year
        merged.month = dateComponents.month
        merged.day = dateComponents.day
        merged.hour = timeComponents.hour
        merged.minute = timeComponents.minute
        merged.second = timeComponents.second

        return cal.date(from: merged)
    }

    // format date -> string iso 8601

    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
            .withSpaceBetweenDateAndTime,
        ]
        return f
    }()

    // set icon date and time TF
    func setIconTextField(_ textField: UITextField, iconName: String) {
        let icon = UIImageView(image: UIImage(systemName: iconName))

        icon.tintColor = UIColor(red: 74/255.0, green: 55/255.0, blue: 128/255.0, alpha: 1.0)

        icon.contentMode = .scaleAspectFit

        let iconContainer = UIView(
            frame: CGRect(x: 0, y: 0, width: 35, height: 20)
        )
        icon.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        iconContainer.addSubview(icon)

        textField.rightView = iconContainer
        textField.rightViewMode = .always
    }

    // set up wheel date time picker

    private func setupPickers() {
        // Configure date picker
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.locale = Locale.current
        }
        // Only allow selecting from today onwards
        let startOfToday = Calendar.current.startOfDay(for: Date())
        datePicker.minimumDate = startOfToday

        dateTF.inputView = datePicker
        dateTF.inputAccessoryView = makeToolbarPicker(
            doneSelector: #selector(doneDate),
            cancelSelector: #selector(cancelEditing)
        )

        // Configure time picker
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker.locale = Locale.current
        }
        timeTF.inputView = timePicker
        timeTF.inputAccessoryView = makeToolbarPicker(
            doneSelector: #selector(doneTime),
            cancelSelector: #selector(cancelEditing)
        )

        // Update text while changing (optional live update)
        datePicker.addTarget(
            self,
            action: #selector(dateChanged(_:)),
            for: .valueChanged
        )
        timePicker.addTarget(
            self,
            action: #selector(timeChanged(_:)),
            for: .valueChanged
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    
    // tool bar of (cancel and done) pickerTime
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
        let date = datePicker.date
        dateTF.text = dateFormatter.string(from: date)
        dateTF.resignFirstResponder()
    }

    @objc private func doneTime() {
        let date = timePicker.date
        timeTF.text = timeFormatter.string(from: date)
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

    // On click 3 btn

    @IBAction func onListCategory(_ sender: Any) {
        category = "list"
        updateCategorySelection()
    }

    @IBAction func onCalendarCategory(_ sender: Any) {
        category = "calendar"
        updateCategorySelection()
    }

    @IBAction func onCupCategory(_ sender: Any) {
        category = "cup"
        updateCategorySelection()
    }

    // Configure system buttons to show background color properly
    private func configureCategoryButtons() {
        // Ensure buttons use a configuration that respects baseBackgroundColor
        [listBtn, calendarBtn, cupBtn].forEach { btn in
            guard let btn = btn else { return }
            var config = btn.configuration ?? .filled()
            config.cornerStyle = .capsule
            // Default colors; will be overridden by updateCategorySelection()
            config.baseBackgroundColor = .white
            config.baseForegroundColor = .black
            btn.configuration = config
        }
        updateCategorySelection()
    }

    // Update selection UI according to category
    private func updateCategorySelection() {
        func apply(_ button: UIButton?, selected: Bool) {
            guard let button = button else { return }
            var config = button.configuration ?? .filled()
            config.cornerStyle = .capsule
            config.baseBackgroundColor = selected ? .black : .white
            config.baseForegroundColor = selected ? .white : .black
            button.configuration = config
        }
        apply(listBtn, selected: category == "list")
        apply(calendarBtn, selected: category == "calendar")
        apply(cupBtn, selected: category == "cup")
    }

}
