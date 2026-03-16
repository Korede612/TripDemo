//
//  TripPlannerViewController.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import UIKit
import Combine

final class TripPlannerViewController: UIViewController {

    // MARK: - ViewModel (unchanged from SwiftUI version)
    private let viewModel: TripPlannerViewModel
    private var coordinator: NavigationCoordinator
    private var cancellables = Set<AnyCancellable>()

    // Hero
    private lazy var heroView: HeroHeaderView = {
        let v = HeroHeaderView()
        v.delegate = self
        return v
    }()

    // Your Trips section
    private let yourTripsLabel = UILabel.make(
        text: "Your Trips",
        font: .systemFont(ofSize: 20, weight: .bold)
    )

    private let tripsSubtitle = UILabel.make(
        text: "Your trip itineraries and planned trips are placed here",
        font: .systemFont(ofSize: 13),
        color: .secondaryLabel,
        lines: 2
    )

    private lazy var statusDropdown: StatusDropdownView = {
        let v = StatusDropdownView()
        v.delegate = self
        return v
    }()

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.separatorStyle = .none
        t.backgroundColor = .clear
        t.showsVerticalScrollIndicator = false
        t.isScrollEnabled = true
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 200
        return t
    }()

    // Error / Empty state
    private let stateView = StateView()

    // MARK: - Lifecycle
    
    init(viewModel: TripPlannerViewModel, coordinator: NavigationCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundGray
        view.addSubview(tableView)
        tableView.fillSuperview()
        setupTableView()
        buildTableHeader()
        statusDropdown.onExpansionChanged = { [weak self] _ in
            guard let self = self else { return }
            self.buildTableHeader()
        }
        bindViewModel()

        Task { await viewModel.loadTrips() }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TripCardCell.self, forCellReuseIdentifier: TripCardCell.reuseID)
        tableView.register(TripSkeletonCell.self, forCellReuseIdentifier: TripSkeletonCell.reuseID)
        tableView.tableFooterView = UIView()
    }

    private func buildTableHeader() {
        // Container view for header
        let headerContainer = UIView()
        headerContainer.backgroundColor = UIColor.backgroundGray

        // Build vertical stack
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0

        headerContainer.addSubview(stack)
        stack.anchor(top: headerContainer.topAnchor,
                     leading: headerContainer.leadingAnchor, leadPad: 0,
                     trailing: headerContainer.trailingAnchor, trailPad: 0,
                     bottom: headerContainer.bottomAnchor)

        // Add hero
        stack.addArrangedSubview(heroView)

        // Section elements
        let sectionContent = UIView()
        stack.addArrangedSubview(sectionContent)

        sectionContent.addSubviews(yourTripsLabel, tripsSubtitle, statusDropdown)

        yourTripsLabel.anchor(top: sectionContent.topAnchor, topPad: 24,
                              leading: sectionContent.leadingAnchor, leadPad: 20,
                              trailing: sectionContent.trailingAnchor, trailPad: 20)

        tripsSubtitle.anchor(top: yourTripsLabel.bottomAnchor, topPad: 4,
                             leading: sectionContent.leadingAnchor, leadPad: 20,
                             trailing: sectionContent.trailingAnchor, trailPad: 20)

        statusDropdown.anchor(top: tripsSubtitle.bottomAnchor, topPad: 16,
                              leading: sectionContent.leadingAnchor, leadPad: 20,
                              trailing: sectionContent.trailingAnchor, trailPad: 20,
                              bottom: sectionContent.bottomAnchor, botPad: 16)

        // Force layout to compute intrinsic height
        let targetWidth = view.bounds.width
        headerContainer.frame = CGRect(x: 0, y: 0, width: targetWidth, height: 1)
        headerContainer.setNeedsLayout()
        headerContainer.layoutIfNeeded()
        let size = headerContainer.systemLayoutSizeFitting(CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
                                                           withHorizontalFittingPriority: .required,
                                                           verticalFittingPriority: .fittingSizeLevel)
        headerContainer.frame.size.height = size.height
        tableView.tableHeaderView = headerContainer
    }

    // MARK: - Bind ViewModel

    private func bindViewModel() {

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.heroView.setLoading(self?.viewModel.isCreatingTrip ?? false)
                self?.reloadUI()
            }
            .store(in: &cancellables)

        viewModel.$trips
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reloadUI() }
            .store(in: &cancellables)

        viewModel.$selectedStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reloadUI() }
            .store(in: &cancellables)

        viewModel.$selectedCity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] city in self?.heroView.setCity(city) }
            .store(in: &cancellables)

        viewModel.$isCreatingTrip
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in self?.heroView.setLoading(loading) }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reloadUI() }
            .store(in: &cancellables)
    }

    // MARK: - Reload

    private func reloadUI() {
        let loading = viewModel.isLoading
        let empty = viewModel.filteredTrips.isEmpty && !loading
        let hasError = viewModel.errorMessage != nil

        tableView.reloadData()

        if hasError, let message = viewModel.errorMessage {
            stateView.show(mode: .error(message))
            showEmptyFooter(true)
        } else if empty {
            stateView.show(mode: .empty)
            showEmptyFooter(true)
        } else {
            showEmptyFooter(false)
        }

        // Recompute header height in case dropdown expanded/collapsed or content changed
        buildTableHeader()
    }

    private func showEmptyFooter(_ show: Bool) {
        if show {
            let headerHeight = tableView.tableHeaderView?.frame.height ?? 0
            let availableHeight = tableView.bounds.height - headerHeight
            let footerHeight = max(availableHeight, 250)

            let footerContainer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight))
            footerContainer.addSubview(stateView)
            stateView.isHidden = false
            stateView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stateView.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor),
                stateView.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor),
                stateView.topAnchor.constraint(equalTo: footerContainer.topAnchor),
                stateView.bottomAnchor.constraint(equalTo: footerContainer.bottomAnchor)
            ])
            tableView.tableFooterView = footerContainer
        } else {
            stateView.removeFromSuperview()
            tableView.tableFooterView = UIView()
        }
    }
}

// MARK: - UITableView DataSource & Delegate

extension TripPlannerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.isLoading ? 3 : viewModel.filteredTrips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.isLoading {
            return tableView.dequeueReusableCell(withIdentifier: TripSkeletonCell.reuseID, for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TripCardCell.reuseID, for: indexPath) as! TripCardCell
        cell.configure(with: viewModel.filteredTrips[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !viewModel.isLoading else { return }
        
        let trip = viewModel.filteredTrips[indexPath.row]
        coordinator.push(.tripDetails(trip: trip))
    }
}

// MARK: - HeroHeaderViewDelegate

extension TripPlannerViewController: HeroHeaderViewDelegate {

    func heroHeaderDidTapSelectCity() {
        coordinator.push(.countryList)
    }

    func heroHeaderDidTapCreateTrip() {
        coordinator.presentSheet(.tripCreate)
    }
    
    func heroHeaderDidTapDatePicker(startDate: Date, endDate: Date) {
        let datePicker = DatePickerViewController()
        datePicker.delegate = self
        datePicker.initialStartDate = startDate
        datePicker.initialEndDate = endDate
        
        if let sheet = datePicker.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(datePicker, animated: true)
    }

    func heroHeaderDidChangeStartDate(_ date: Date) {
        viewModel.startDate = date
    }

    func heroHeaderDidChangeEndDate(_ date: Date) {
        viewModel.endDate = date
    }
}

// MARK: - DatePickerViewControllerDelegate

extension TripPlannerViewController: DatePickerViewControllerDelegate {
    func datePicker(_ vc: DatePickerViewController, didSelectStartDate: Date, endDate: Date) {
        viewModel.startDate = didSelectStartDate
        viewModel.endDate = endDate
        heroView.setDates(startDate: didSelectStartDate, endDate: endDate)
    }
}

// MARK: - StatusDropdownViewDelegate

extension TripPlannerViewController: StatusDropdownViewDelegate {
    func statusDropdown(_ view: StatusDropdownView, didSelect status: TripStatus) {
        viewModel.selectStatus(status)
    }
}

// MARK: - StateView (empty / error)

final class StateView: UIView {

    enum Mode {
        case empty
        case error(String)
    }

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray3
        return iv
    }()

    private let titleLabel = UILabel.make(
        font: .systemFont(ofSize: 16, weight: .semibold),
        color: .secondaryLabel,
        alignment: .center
    )

    private let subtitleLabel = UILabel.make(
        font: .systemFont(ofSize: 13),
        color: .tertiaryLabel,
        lines: 2,
        alignment: .center
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        addSubview(stack)
        stack.centerInSuperview()
        iconView.anchor(width: 56, height: 56)
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError() }

    func show(mode: Mode) {
        isHidden = false
        switch mode {
        case .empty:
            let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .thin)
            iconView.image = UIImage(systemName: "map", withConfiguration: config)
            titleLabel.text = "No trips yet"
            subtitleLabel.text = "Create your first trip above!"
        case .error(let msg):
            let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .regular)
            iconView.image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: config)
            iconView.tintColor = .systemOrange
            titleLabel.text = "Something went wrong"
            subtitleLabel.text = msg
        }
    }
}

