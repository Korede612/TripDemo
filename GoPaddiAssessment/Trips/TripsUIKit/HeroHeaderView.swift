//
//  HeroHeaderView.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import UIKit
import SwiftUI

// MARK: - Delegate
protocol HeroHeaderViewDelegate: AnyObject {
    func heroHeaderDidTapSelectCity()
    func heroHeaderDidTapCreateTrip()
    func heroHeaderDidChangeStartDate(_ date: Date)
    func heroHeaderDidChangeEndDate(_ date: Date)
    func heroHeaderDidTapDatePicker(startDate: Date, endDate: Date)
}

final class HeroHeaderView: UIView {

    weak var delegate: HeroHeaderViewDelegate?

    // MARK: - Subviews

    private let gradientLayer = CAGradientLayer()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Plan Your Dream Trip\nin Minutes"
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.numberOfLines = 2
        l.textColor = .black
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Build, personalize, and optimize your itineraries with our trip planner. Perfect for getaways, remote workcations, and any spontaneous escapade."
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

//    private let avatarView: UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor(hex: "#E040FB")
//        v.layer.cornerRadius = 21
//        v.clipsToBounds = true
//        let l = UILabel.make(text: "D", font: .systemFont(ofSize: 18, weight: .semibold), color: .white, alignment: .center)
//        v.addSubview(l)
//        l.fillSuperview()
//        return v
//    }()

    // Hotel decoration
    private let hotelIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .thin)
        iv.image = UIImage(systemName: "building.2.fill", withConfiguration: config)
        iv.tintColor = UIColor(hex: "#B8D4E0").withAlphaComponent(0.4)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Booking Card

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 12
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v
    }()

    // City row
    private let cityIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18)
        iv.image = UIImage(systemName: "mappin.circle", withConfiguration: config)
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let cityTopLabel = UILabel.make(
        text: "Where to ?",
        font: .systemFont(ofSize: 11),
        color: .secondaryLabel
    )

    private(set) var cityValueLabel = UILabel.make(
        text: "Select City",
        font: .systemFont(ofSize: 15, weight: .semibold),
        color: .label
    )

    private let cityDivider: UIView = {
        let v = UIView(); v.backgroundColor = UIColor.separator; return v
    }()

    // Date row
    private let startDateLabel = UILabel.make(
        text: "Start Date",
        font: .systemFont(ofSize: 11),
        color: .secondaryLabel
    )
    private let startCalIcon = HeroHeaderView.calendarIcon()
    private(set) var startDatePicker: UIDatePicker = HeroHeaderView.datePicker()
    
    // Tap-to-open date picker button (overlay)
    private let dateSelectionButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .clear
        return b
    }()

    private let endDateLabel = UILabel.make(
        text: "End Date",
        font: .systemFont(ofSize: 11),
        color: .secondaryLabel
    )
    private let endCalIcon = HeroHeaderView.calendarIcon()
    private(set) var endDatePicker: UIDatePicker = HeroHeaderView.datePicker(offsetDays: 5)

    private let dateDivider: UIView = {
        let v = UIView(); v.backgroundColor = UIColor.separator; return v
    }()

    private let verticalDateDivider: UIView = {
        let v = UIView(); v.backgroundColor = UIColor.separator; return v
    }()

    // CTA button
    private(set) var createButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Create a Trip", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .brand.withAlphaComponent(0.4)
        b.layer.cornerRadius = 10
        b.isEnabled = false
        b.isUserInteractionEnabled = false
        return b
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        setupLayout()
        setupActions()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    // MARK: - Gradient

    private func setupGradient() {
        gradientLayer.colors = [UIColor(hex: "#E8F4F8").cgColor, UIColor(hex: "#D0E8F0").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Layout

    private func setupLayout() {
        addSubviews(hotelIcon, titleLabel, subtitleLabel, cardView)

        // Hotel deco (behind text, aligned right/top)
        hotelIcon.anchor(top: topAnchor, topPad: 44, trailing: trailingAnchor, trailPad: 20, width: 110, height: 110)

        // Title
        titleLabel.anchor(top: topAnchor, topPad: 56, leading: leadingAnchor, leadPad: 20, trailing: trailingAnchor, trailPad: 8)

        // Subtitle
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, topPad: 6, leading: leadingAnchor, leadPad: 20, trailing: trailingAnchor, trailPad: 20)

        // Card
        cardView.anchor(top: subtitleLabel.bottomAnchor, topPad: 20, leading: leadingAnchor, leadPad: 20, trailing: trailingAnchor, trailPad: 20, bottom: bottomAnchor, botPad: 28)

        buildCardLayout()
    }

    private func buildCardLayout() {
        // -- City row --
        let cityRow = UIView()
        cardView.addSubview(cityRow)
        cityRow.anchor(top: cardView.topAnchor, leading: cardView.leadingAnchor, trailing: cardView.trailingAnchor)

        cityRow.addSubviews(cityIcon, cityTopLabel, cityValueLabel)
        cityIcon.anchor(leading: cityRow.leadingAnchor, leadPad: 16, width: 22, height: 22)
        cityIcon.centerYAnchor.constraint(equalTo: cityRow.centerYAnchor).isActive = true

        let cityTextStack = UIStackView(arrangedSubviews: [cityTopLabel, cityValueLabel])
        cityTextStack.axis = .vertical
        cityTextStack.spacing = 2
        cityRow.addSubview(cityTextStack)
        cityTextStack.anchor(top: cityRow.topAnchor, topPad: 14,
                             leading: cityIcon.trailingAnchor, leadPad: 12,
                             trailing: cityRow.trailingAnchor, trailPad: 16,
                             bottom: cityRow.bottomAnchor, botPad: 14)

        // make city row tappable
        let tap = UITapGestureRecognizer(target: self, action: #selector(cityTapped))
        cityRow.addGestureRecognizer(tap)
        cityRow.isUserInteractionEnabled = true

        // -- Divider --
        cardView.addSubview(cityDivider)
        cityDivider.anchor(top: cityRow.bottomAnchor, leading: cardView.leadingAnchor, leadPad: 16, trailing: cardView.trailingAnchor, trailPad: 16, height: 0.5)

        // -- Date row --
        let dateRow = UIView()
        cardView.addSubview(dateRow)
        dateRow.anchor(top: cityDivider.bottomAnchor, leading: cardView.leadingAnchor, trailing: cardView.trailingAnchor)

        // Start date column
        let startCol = makeDateColumn(icon: startCalIcon, label: startDateLabel, picker: startDatePicker)
        startCol.backgroundColor = UIColor(hex: "#E4E7EC") //?? UIColor.gray.withAlphaComponent(0.3)
        startCol.layer.cornerRadius = 4
        // End date column
        let endCol = makeDateColumn(icon: endCalIcon, label: endDateLabel, picker: endDatePicker)

        endCol.backgroundColor = UIColor(hex: "#E4E7EC") //?? UIColor.gray.withAlphaComponent(0.3)
        endCol.layer.cornerRadius = 4
        
        dateRow.addSubviews(startCol, verticalDateDivider, endCol)
        startCol.anchor(top: dateRow.topAnchor, topPad: 10, leading: dateRow.leadingAnchor, leadPad: 16, bottom: dateRow.bottomAnchor, botPad: 10)

        verticalDateDivider.anchor(leading: startCol.trailingAnchor, leadPad: 8, width: 0.5)
        verticalDateDivider.centerYAnchor.constraint(equalTo: dateRow.centerYAnchor).isActive = true
        verticalDateDivider.heightAnchor.constraint(equalToConstant: 44).isActive = true

        endCol.anchor(top: dateRow.topAnchor, topPad: 10, leading: verticalDateDivider.trailingAnchor, leadPad: 8, trailing: dateRow.trailingAnchor, trailPad: 16, bottom: dateRow.bottomAnchor, botPad: 10)
        startCol.widthAnchor.constraint(equalTo: endCol.widthAnchor).isActive = true
        
        // Add overlay button for date picker
        dateRow.addSubview(dateSelectionButton)
        dateSelectionButton.fillSuperview()

        // -- Divider --
        cardView.addSubview(dateDivider)
        dateDivider.anchor(top: dateRow.bottomAnchor, leading: cardView.leadingAnchor, leadPad: 16, trailing: cardView.trailingAnchor, trailPad: 16, height: 0.5)

        // -- Create button --
        cardView.addSubview(createButton)
        createButton.anchor(top: dateDivider.bottomAnchor, topPad: 16,
                            leading: cardView.leadingAnchor, leadPad: 16,
                            trailing: cardView.trailingAnchor, trailPad: 16,
                            bottom: cardView.bottomAnchor, botPad: 16,
                            height: 50)

        createButton.addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }

    private func makeDateColumn(icon: UIImageView, label: UILabel, picker: UIDatePicker) -> UIStackView {
        let iconLabelRow = UIStackView(arrangedSubviews: [icon, label])
        iconLabelRow.axis = .horizontal
        iconLabelRow.spacing = 6
        iconLabelRow.alignment = .center
        icon.widthAnchor.constraint(equalToConstant: 18).isActive = true

        let col = UIStackView(arrangedSubviews: [iconLabelRow, picker])
        col.axis = .vertical
        col.spacing = 4
        col.alignment = .leading
        col.translatesAutoresizingMaskIntoConstraints = false
        return col
    }

    // MARK: - Actions

    private func setupActions() {
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        dateSelectionButton.addTarget(self, action: #selector(dateSelectionTapped), for: .touchUpInside)
    }

    @objc private func cityTapped() { delegate?.heroHeaderDidTapSelectCity() }
    @objc private func createTapped() { delegate?.heroHeaderDidTapCreateTrip() }
    @objc private func dateSelectionTapped() {
        delegate?.heroHeaderDidTapDatePicker(startDate: startDatePicker.date, endDate: endDatePicker.date)
    }
    @objc private func startDateChanged() {
        // Ensure end date cannot be earlier than start date
        let startDay = Calendar.current.startOfDay(for: startDatePicker.date)
        endDatePicker.minimumDate = startDay
        
        // If current end date is earlier than the new minimum, bump it to the minimum
        if let endDate = endDatePicker.date as Date?, endDate < startDay {
            endDatePicker.date = startDay
        }
        
        delegate?.heroHeaderDidChangeStartDate(startDatePicker.date)
    }
    @objc private func endDateChanged()   { delegate?.heroHeaderDidChangeEndDate(endDatePicker.date) }

    // MARK: - Public update methods

    func setCity(_ city: String) {
        cityValueLabel.text = city.isEmpty ? "Select City" : city
        cityValueLabel.textColor = city.isEmpty ? .label : .brand
        createButton.backgroundColor = .brand.withAlphaComponent(city.isEmpty ? 0.4 : 1)
        createButton.isEnabled = !city.isEmpty
        createButton.isUserInteractionEnabled = !city.isEmpty
    }

    func setLoading(_ loading: Bool) {
        createButton.setTitle(loading ? nil : "Create a Trip", for: .normal)
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        createButton.isEnabled = !loading
    }
    
    func setDates(startDate: Date, endDate: Date) {
        startDatePicker.date = startDate
        endDatePicker.date = endDate
        
        // Update minimum date for end picker
        let startDay = Calendar.current.startOfDay(for: startDate)
        endDatePicker.minimumDate = startDay
    }

    // MARK: - Helpers

    private static func calendarIcon() -> UIImageView {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        iv.image = UIImage(systemName: "calendar", withConfiguration: config)
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        return iv
    }

    private static func datePicker(offsetDays: Int = 0) -> UIDatePicker {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact

        // Disallow past dates
        let todayStart = Calendar.current.startOfDay(for: Date())
        dp.minimumDate = todayStart

        // Set initial date (e.g., today + offsetDays)
        dp.date = Calendar.current.date(byAdding: .day, value: offsetDays, to: todayStart) ?? todayStart

        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }
}
