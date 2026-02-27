//
//  StatusDropdownView.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import UIKit

protocol StatusDropdownViewDelegate: AnyObject {
    func statusDropdown(_ view: StatusDropdownView, didSelect status: TripStatus)
}

final class StatusDropdownView: UIView {

    weak var delegate: StatusDropdownViewDelegate?
    // Notify external listeners when expanded/collapsed state changes
    var onExpansionChanged: ((Bool) -> Void)?
    private(set) var selectedStatus: TripStatus = .planned

    // MARK: - Subviews

    private let triggerButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .white
        b.contentHorizontalAlignment = .leading
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.setTitleColor(.label, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        b.layer.cornerRadius = 10
        b.clipsToBounds = true
        return b
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.down", withConfiguration: config)
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let dropdownContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        v.alpha = 0
        v.isHidden = true
        return v
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 0
        return sv
    }()

    private let optionsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 0
        return sv
    }()

    private var rowViews: [StatusRowView] = []
    private var isExpanded = false

    // Height constraint for animated expansion
    private var containerHeightConstraint: NSLayoutConstraint!
    private var heightPerRow: CGFloat = 46

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        updateTriggerLabel()
        applyShadow(expanded: false)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupViews() {
        addSubviews(contentStack)
        contentStack.addArrangedSubview(triggerButton)
        contentStack.addArrangedSubview(dropdownContainer)

        // Trigger button fills top
//        triggerButton.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        contentStack.fillSuperview()
        triggerButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        // Chevron inside button
        triggerButton.addSubview(chevron)
        chevron.anchor(trailing: triggerButton.trailingAnchor, trailPad: 14, width: 16, height: 16)
        chevron.centerYAnchor.constraint(equalTo: triggerButton.centerYAnchor).isActive = true

        // Dropdown sits right below trigger
//        dropdownContainer.anchor(top: triggerButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)

        // Build rows using a vertical stack view
        dropdownContainer.addSubview(optionsStack)
        optionsStack.anchor(top: dropdownContainer.topAnchor, leading: dropdownContainer.leadingAnchor, trailing: dropdownContainer.trailingAnchor, bottom: dropdownContainer.bottomAnchor)

        // Optional top divider
        let topDivider = UIView()
        topDivider.backgroundColor = .separator
        dropdownContainer.addSubview(topDivider)
        topDivider.anchor(top: dropdownContainer.topAnchor, leading: dropdownContainer.leadingAnchor, trailing: dropdownContainer.trailingAnchor, height: 0.5)

        rowViews.removeAll()
        for (index, status) in TripStatus.allCases.enumerated() {
            let row = StatusRowView(status: status, isSelected: status == selectedStatus)
            row.onTap = { [weak self] in self?.selectStatus(status) }
            optionsStack.addArrangedSubview(row)
            row.heightAnchor.constraint(equalToConstant: heightPerRow).isActive = true

            if index < TripStatus.allCases.count - 1 {
                let sep = UIView()
                sep.backgroundColor = .separator
                sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                optionsStack.addArrangedSubview(sep)
            }
            rowViews.append(row)
        }

        triggerButton.addTarget(self, action: #selector(toggleDropdown), for: .touchUpInside)
    }

    // MARK: - Toggle

    @objc private func toggleDropdown() {
        isExpanded ? collapse() : expand()
    }

    private func expand() {
        isExpanded = true
        dropdownContainer.isHidden = false

        // Round only top corners on trigger while open
        triggerButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        dropdownContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dropdownContainer.alpha = 1
            self.chevron.transform = CGAffineTransform(rotationAngle: .pi)
            self.applyShadow(expanded: true)
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.onExpansionChanged?(true)
        }
    }

    private func collapse() {
        isExpanded = false

        triggerButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.dropdownContainer.alpha = 0
            self.chevron.transform = .identity
            self.applyShadow(expanded: false)
            self.superview?.layoutIfNeeded()
        }) { _ in
            self.dropdownContainer.isHidden = true
            self.onExpansionChanged?(false)
        }
    }

    private func selectStatus(_ status: TripStatus) {
        selectedStatus = status
        updateTriggerLabel()
        rowViews.forEach { $0.setSelected($0.status == status) }
        collapse()
        delegate?.statusDropdown(self, didSelect: status)
    }

    // MARK: - Helpers

    private func updateTriggerLabel() {
        triggerButton.setTitle(selectedStatus.rawValue, for: .normal)
    }

    private func applyShadow(expanded: Bool) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = expanded ? 0.12 : 0.06
        layer.shadowRadius  = expanded ? 12 : 4
        layer.shadowOffset  = CGSize(width: 0, height: expanded ? 6 : 2)
    }
}

// MARK: - StatusRowView

final class StatusRowView: UIView {

    let status: TripStatus
    var onTap: (() -> Void)?

    private let titleLabel: UILabel
    private let checkmark: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        iv.image = UIImage(systemName: "checkmark", withConfiguration: config)
        iv.tintColor = .brand
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    init(status: TripStatus, isSelected: Bool) {
        self.status = status
        titleLabel = UILabel.make(
            text: status.rawValue,
            font: .systemFont(ofSize: 14, weight: isSelected ? .semibold : .regular),
            color: isSelected ? .brand : .label
        )
        super.init(frame: .zero)
        setupViews()
        setSelected(isSelected)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        addSubviews(titleLabel, checkmark)
        titleLabel.anchor(leading: leadingAnchor, leadPad: 14, trailing: checkmark.leadingAnchor, trailPad: 8)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        checkmark.anchor(trailing: trailingAnchor, trailPad: 14, width: 16, height: 16)
        checkmark.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? UIColor.brand.withAlphaComponent(0.06) : .white
        titleLabel.textColor = selected ? .brand : .label
        titleLabel.font = .systemFont(ofSize: 14, weight: selected ? .semibold : .regular)
        checkmark.isHidden = !selected
    }

    @objc private func tapped() { onTap?() }
}

