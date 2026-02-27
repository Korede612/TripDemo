//
//  DatePickerViewController.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import UIKit

protocol DatePickerViewControllerDelegate: AnyObject {
    func datePicker(_ vc: DatePickerViewController, didSelectStartDate: Date, endDate: Date)
}

final class DatePickerViewController: UIViewController {

    weak var delegate: DatePickerViewControllerDelegate?
    
    // Input dates
    var initialStartDate: Date = Date()
    var initialEndDate: Date = {
        Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    }()
    
    // MARK: - UI Components
    
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        b.tintColor = .label
        return b
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Date"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .label
        return l
    }()
    
    private let calendarView: UICalendarView = {
        let cv = UICalendarView()
        cv.calendar = .current
        cv.locale = .current
        cv.fontDesign = .rounded
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let startDateTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.textAlignment = .center
        tf.font = .systemFont(ofSize: 15)
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    private let endDateTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.textAlignment = .center
        tf.font = .systemFont(ofSize: 15)
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    private let startDateLabel = UILabel.make(
        text: "Start Date",
        font: .systemFont(ofSize: 13),
        color: .secondaryLabel
    )
    
    private let endDateLabel = UILabel.make(
        text: "End Date",
        font: .systemFont(ofSize: 13),
        color: .secondaryLabel
    )
    
    private let chooseButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Choose Date", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .brand
        b.layer.cornerRadius = 10
        return b
    }()
    
    // MARK: - Properties
    
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    private var isSelectingStart = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupLayout()
        setupCalendar()
        setupActions()
        
        // Initialize with provided dates
        selectedStartDate = initialStartDate
        selectedEndDate = initialEndDate
        updateDateTextFields()
        updateCalendarSelection()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        view.addSubviews(closeButton, titleLabel, calendarView)
        
        closeButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            topPad: 16,
            leading: view.leadingAnchor,
            leadPad: 20,
            width: 32,
            height: 32
        )
        
        titleLabel.anchor(
            leading: closeButton.trailingAnchor,
            leadPad: 12
        )
        titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        
        calendarView.anchor(
            top: titleLabel.bottomAnchor,
            topPad: 20,
            leading: view.leadingAnchor,
            leadPad: 16,
            trailing: view.trailingAnchor,
            trailPad: 16
        )
        
        // Date fields container
        let dateFieldsContainer = UIView()
        view.addSubview(dateFieldsContainer)
        dateFieldsContainer.anchor(
            top: calendarView.bottomAnchor,
            topPad: 20,
            leading: view.leadingAnchor,
            leadPad: 20,
            trailing: view.trailingAnchor,
            trailPad: 20
        )
        
        // Start date column
        let startStack = UIStackView(arrangedSubviews: [startDateLabel, startDateTextField])
        startStack.axis = .vertical
        startStack.spacing = 8
        
        // End date column
        let endStack = UIStackView(arrangedSubviews: [endDateLabel, endDateTextField])
        endStack.axis = .vertical
        endStack.spacing = 8
        
        // Horizontal stack for both date fields
        let fieldsStack = UIStackView(arrangedSubviews: [startStack, endStack])
        fieldsStack.axis = .horizontal
        fieldsStack.spacing = 16
        fieldsStack.distribution = .fillEqually
        
        dateFieldsContainer.addSubview(fieldsStack)
        fieldsStack.fillSuperview()
        
        startDateTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        endDateTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Choose button
        view.addSubview(chooseButton)
        chooseButton.anchor(
            top: dateFieldsContainer.bottomAnchor,
            topPad: 20,
            leading: view.leadingAnchor,
            leadPad: 20,
            trailing: view.trailingAnchor,
            trailPad: 20,
            height: 50
        )
        
        // Add bottom spacing
        let spacer = UIView()
        view.addSubview(spacer)
        spacer.anchor(
            top: chooseButton.bottomAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            botPad: 20,
            height: 1
        )
    }
    
    // MARK: - Calendar Setup
    
    private func setupCalendar() {
        // Disable past dates
        let todayStart = Calendar.current.startOfDay(for: Date())
        calendarView.availableDateRange = DateInterval(start: todayStart, end: Date.distantFuture)
        
        // Multi-date selection
        let selection = UICalendarSelectionMultiDate(delegate: self)
        calendarView.selectionBehavior = selection
    }
    
    private func updateCalendarSelection() {
        guard let selection = calendarView.selectionBehavior as? UICalendarSelectionMultiDate,
              let start = selectedStartDate,
              let end = selectedEndDate else { return }
        
        // Get all dates between start and end
        var dates: [DateComponents] = []
        var currentDate = start
        
        while currentDate <= end {
            dates.append(Calendar.current.dateComponents([.year, .month, .day], from: currentDate))
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        selection.setSelectedDates(dates, animated: false)
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        chooseButton.addTarget(self, action: #selector(chooseTapped), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func chooseTapped() {
        guard let start = selectedStartDate, let end = selectedEndDate else { return }
        delegate?.datePicker(self, didSelectStartDate: start, endDate: end)
        dismiss(animated: true)
    }
    
    // MARK: - Date Updates
    
    private func updateDateTextFields() {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        
        if let start = selectedStartDate {
            startDateTextField.text = formatter.string(from: start)
            startDateTextField.layer.borderColor = UIColor.brand.cgColor
            startDateTextField.layer.borderWidth = 2
        }
        
        if let end = selectedEndDate {
            endDateTextField.text = formatter.string(from: end)
            endDateTextField.layer.borderColor = UIColor.brand.cgColor
            endDateTextField.layer.borderWidth = 2
        }
    }
    
    private func handleDateSelection(_ dateComponents: DateComponents) {
        guard let selectedDate = Calendar.current.date(from: dateComponents) else { return }
        
        let todayStart = Calendar.current.startOfDay(for: Date())
        let normalizedSelected = Calendar.current.startOfDay(for: selectedDate)
        
        // Don't allow past dates
        guard normalizedSelected >= todayStart else { return }
        
        if isSelectingStart {
            selectedStartDate = normalizedSelected
            
            // Auto-adjust end date if it's before the new start date
            if let end = selectedEndDate, end < normalizedSelected {
                selectedEndDate = normalizedSelected
            }
            
            isSelectingStart = false
        } else {
            selectedEndDate = normalizedSelected
            
            // If end date is before start date, swap them
            if let start = selectedStartDate, normalizedSelected < start {
                selectedEndDate = start
                selectedStartDate = normalizedSelected
            }
            
            isSelectingStart = true
        }
        
        updateDateTextFields()
        updateCalendarSelection()
    }
}

// MARK: - UICalendarSelectionMultiDateDelegate

extension DatePickerViewController: UICalendarSelectionMultiDateDelegate {
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        handleDateSelection(dateComponents)
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        // Handle deselection if needed
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canSelectDate dateComponents: DateComponents) -> Bool {
        // Only allow dates from today onwards
        guard let date = Calendar.current.date(from: dateComponents) else { return false }
        let todayStart = Calendar.current.startOfDay(for: Date())
        return date >= todayStart
    }
}
