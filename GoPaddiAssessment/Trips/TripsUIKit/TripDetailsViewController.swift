//
//  TripDetailsViewController.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import UIKit

final class TripDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let trip: Trip
    private var coordinator: NavigationCoordinator
    
    // MARK: - Subviews
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.alwaysBounceVertical = true
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    // Header image with gradient
    private lazy var headerImageView: RemoteImageView = {
        let iv = RemoteImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(hex: "#B8D4E0")
        return iv
    }()
    
    private let gradientOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 1]
        return gradient
    }()
    
    // Back button
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    
    // Trip info overlay on header
    private let tripInfoContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    private let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let tripTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    // Action buttons
    private let actionButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var collaborationButton = makeActionButton(
        icon: "person.2.fill",
        title: "Trip Collaboration",
        color: UIColor(hex: "#2196F3")
    )
    
    private lazy var shareButton = makeActionButton(
        icon: "square.and.arrow.up",
        title: "Share Trip",
        color: UIColor(hex: "#2196F3")
    )
    
    // Section cards
    private lazy var activitiesCard = makeSectionCard(
        icon: "figure.walk",
        title: "Activities",
        subtitle: "Build, personalize, and optimize your itineraries with our trip planner.",
        buttonTitle: "Add Activities",
        iconColor: UIColor(hex: "#2196F3")
    )
    
    private lazy var hotelsCard = makeSectionCard(
        icon: "building.2.fill",
        title: "Hotels",
        subtitle: "Build, personalize, and optimize your itineraries with our trip planner.",
        buttonTitle: "Add Hotels",
        iconColor: UIColor(hex: "#2196F3")
    )
    
    private lazy var flightsCard = makeSectionCard(
        icon: "airplane",
        title: "Flights",
        subtitle: "Build, personalize, and optimize your itineraries with our trip planner.",
        buttonTitle: "Add Flights",
        iconColor: UIColor(hex: "#2196F3")
    )
    
    // Trip Itineraries section
    private let itinerariesHeaderView = UIView()
    private let itinerariesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Trip Itineraries"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let itinerariesSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your trip itineraries are placed here"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Placeholder for empty state or items
    private lazy var itinerariesContentView = makeItinerariesPlaceholder()
    
    // MARK: - Lifecycle
    
    init(trip: Trip, coordinator: NavigationCoordinator) {
        self.trip = trip
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundGray
        setupNavigation()
        setupLayout()
        configureContent()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientOverlay.bounds
    }
    
    // MARK: - Setup
    
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        scrollView.addSubview(contentStack)
        contentStack.anchor(
            top: scrollView.topAnchor,
            leading: scrollView.leadingAnchor,
            trailing: scrollView.trailingAnchor,
            bottom: scrollView.bottomAnchor
        )
        contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        // Header with image
        let headerContainer = UIView()
        headerContainer.addSubview(headerImageView)
        headerImageView.fillSuperview()
        
        headerImageView.addSubview(gradientOverlay)
        gradientOverlay.fillSuperview()
        gradientOverlay.layer.addSublayer(gradientLayer)
        
        // Back button
        headerContainer.addSubview(backButton)
        backButton.anchor(
            top: headerContainer.topAnchor,
            topPad: 50,
            leading: headerContainer.leadingAnchor,
            leadPad: 16,
            width: 40,
            height: 40
        )
        
        // Trip info on header
        headerContainer.addSubview(tripInfoContainer)
        tripInfoContainer.anchor(
            leading: headerContainer.leadingAnchor,
            leadPad: 20,
            trailing: headerContainer.trailingAnchor,
            trailPad: 20,
            bottom: headerContainer.bottomAnchor,
            botPad: 16
        )
        
        let infoStack = UIStackView(arrangedSubviews: [
            dateRangeLabel,
            tripTitleLabel,
            locationLabel
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        
        tripInfoContainer.addSubview(infoStack)
        infoStack.fillSuperview()
        
        headerContainer.heightAnchor.constraint(equalToConstant: 240).isActive = true
        
        contentStack.addArrangedSubview(headerContainer)
        
        // Action buttons
        let actionsContainer = UIView()
        actionsContainer.addSubview(actionButtonsStack)
        actionButtonsStack.anchor(
            top: actionsContainer.topAnchor,
            topPad: 16,
            leading: actionsContainer.leadingAnchor,
            leadPad: 20,
            trailing: actionsContainer.trailingAnchor,
            trailPad: 20,
            bottom: actionsContainer.bottomAnchor,
            botPad: 8
        )
        
        actionButtonsStack.addArrangedSubview(collaborationButton)
        actionButtonsStack.addArrangedSubview(shareButton)
        
        collaborationButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        contentStack.addArrangedSubview(actionsContainer)
        
        // Section cards
        let cardsContainer = UIView()
        let cardsStack = UIStackView(arrangedSubviews: [
            activitiesCard,
            hotelsCard,
            flightsCard
        ])
        cardsStack.axis = .vertical
        cardsStack.spacing = 16
        
        cardsContainer.addSubview(cardsStack)
        cardsStack.anchor(
            top: cardsContainer.topAnchor,
            topPad: 8,
            leading: cardsContainer.leadingAnchor,
            leadPad: 20,
            trailing: cardsContainer.trailingAnchor,
            trailPad: 20,
            bottom: cardsContainer.bottomAnchor,
            botPad: 8
        )
        
        contentStack.addArrangedSubview(cardsContainer)
        
        // Trip Itineraries section
        let itinerariesContainer = UIView()
        
        itinerariesContainer.addSubview(itinerariesHeaderView)
        itinerariesHeaderView.anchor(
            top: itinerariesContainer.topAnchor,
            topPad: 8,
            leading: itinerariesContainer.leadingAnchor,
            leadPad: 20,
            trailing: itinerariesContainer.trailingAnchor,
            trailPad: 20
        )
        
        let headerStack = UIStackView(arrangedSubviews: [
            itinerariesTitleLabel,
            itinerariesSubtitleLabel
        ])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        
        itinerariesHeaderView.addSubview(headerStack)
        headerStack.fillSuperview()
        
        itinerariesContainer.addSubview(itinerariesContentView)
        itinerariesContentView.anchor(
            top: itinerariesHeaderView.bottomAnchor,
            topPad: 16,
            leading: itinerariesContainer.leadingAnchor,
            leadPad: 20,
            trailing: itinerariesContainer.trailingAnchor,
            trailPad: 20,
            bottom: itinerariesContainer.bottomAnchor,
            botPad: 40
        )
        
        contentStack.addArrangedSubview(itinerariesContainer)
    }
    
    private func configureContent() {
        // Load header image
        headerImageView.load(urlString: trip.imageURL)
        
        // Date range
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        let startStr = formatter.string(from: trip.startDate)
        let endStr = formatter.string(from: trip.endDate)
        dateRangeLabel.text = "📅 \(startStr) - \(endStr)"
        
        // Title
        tripTitleLabel.text = trip.title
        
        // Location
        locationLabel.text = "📍 \(trip.destination)"
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Factory Methods
    
    private func makeActionButton(icon: String, title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let image = UIImage(systemName: icon, withConfiguration: config)
        
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.tintColor = color
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        
        button.contentHorizontalAlignment = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        
        // Shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.05
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        return button
    }
    
    private func makeSectionCard(icon: String, title: String, subtitle: String, buttonTitle: String, iconColor: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.06
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Icon
        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        // Button
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = iconColor
        button.layer.cornerRadius = 8
        
        // Layout
        container.addSubviews(iconView, titleLabel, subtitleLabel, button)
        
        iconView.anchor(
            top: container.topAnchor,
            topPad: 16,
            leading: container.leadingAnchor,
            leadPad: 16,
            width: 40,
            height: 40
        )
        
        titleLabel.anchor(
            top: iconView.bottomAnchor,
            topPad: 12,
            leading: container.leadingAnchor,
            leadPad: 16,
            trailing: container.trailingAnchor,
            trailPad: 16
        )
        
        subtitleLabel.anchor(
            top: titleLabel.bottomAnchor,
            topPad: 4,
            leading: container.leadingAnchor,
            leadPad: 16,
            trailing: container.trailingAnchor,
            trailPad: 16
        )
        
        button.anchor(
            top: subtitleLabel.bottomAnchor,
            topPad: 16,
            leading: container.leadingAnchor,
            leadPad: 16,
            trailing: container.trailingAnchor,
            trailPad: 16,
            bottom: container.bottomAnchor,
            botPad: 16,
            height: 44
        )
        
        return container
    }
    
    private func makeItinerariesPlaceholder() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.06
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Icon
        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        iconView.image = UIImage(systemName: "airplane", withConfiguration: config)
        iconView.tintColor = UIColor(hex: "#2196F3").withAlphaComponent(0.4)
        iconView.contentMode = .scaleAspectFit
        
        // Label
        let label = UILabel()
        label.text = "No request yet"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        
        // Button
        let button = UIButton(type: .system)
        button.setTitle("Add Flight", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#2196F3")
        button.layer.cornerRadius = 8
        
        // Layout
        let stack = UIStackView(arrangedSubviews: [iconView, label, button])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        
        container.addSubview(stack)
        stack.centerInSuperview()
        stack.anchor(
            leading: container.leadingAnchor,
            leadPad: 40,
            trailing: container.trailingAnchor,
            trailPad: 40
        )
        
        iconView.anchor(width: 80, height: 80)
        
        button.anchor(
            leading: stack.leadingAnchor,
            trailing: stack.trailingAnchor,
            height: 44
        )
        
        container.heightAnchor.constraint(equalToConstant: 240).isActive = true
        
        return container
    }
}
