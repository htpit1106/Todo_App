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
    var onSaveTask: ((Todo) -> Void)?
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

    var clickedBtn: String?
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
        setIconTextField(dateTF, iconName: "calendar")
        setIconTextField(timeTF, iconName: "clock")
        setupPickers()

        let now = Date()
        dateTF.text = dateFormatter.string(from: now)
        timeTF.text = timeFormatter.string(from: now)

        // color placeholder
        titleTF.attributedPlaceholder = NSAttributedString(
            string: "Task Title",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray2
            ]
        )

    }

    // btn save
    @IBAction func onPressSaveBtn(_ sender: Any) {
        let id = UUID().uuidString
        let title = titleTF.text
        // time = date + time
        let pickedDate = datePicker.date
        let pickedTime = timePicker.date

        // Ghép thành 1 Date duy nhất
        guard let combined = combine(date: pickedDate, time: pickedTime) else {
            return
        }
        // Định dạng sang ISO 8601
        let times = isoFormatter.string(from: combined)
        // Ví dụ: "2025-10-15T09:30:00+07:00" hoặc "2025-10-15T02:30:00Z" nếu set UTC
        let content = notesTV.text
        let category = clickedBtn

        // validate

        let newTask = Todo(
            id: id,
            title: title,
            category: category,
            created_at: isoFormatter.string(from: Date()),
            content: content,
            time: times,
            isCompleted: false
        )

        onSaveTask?(newTask)
        navigationController?.popViewController(animated: true)

    }

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
        icon.tintColor = UIColor.systemPurple
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

    // su ly click 3 btn

    @IBAction func onListCategory(_ sender: Any) {
        clickedBtn = "list"
        listBtn.alpha = 0.5
        calendarBtn.alpha = 1.0
        cupBtn.alpha = 1.0

    }

    @IBAction func onCalendarCategory(_ sender: Any) {
        clickedBtn = "calendar"
        listBtn.alpha = 1.0
        calendarBtn.alpha = 0.5
        cupBtn.alpha = 1.0
    }

    @IBAction func onCupCategory(_ sender: Any) {
        clickedBtn = "cup"
        listBtn.alpha = 1.0
        calendarBtn.alpha = 1.0
        cupBtn.alpha = 0.5
    }
}

