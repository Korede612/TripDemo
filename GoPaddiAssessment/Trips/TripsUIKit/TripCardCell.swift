//
//  TripCardCell.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import UIKit

final class TripCardCell: UITableViewCell {
    static let reuseID = "TripCardCell"

    // MARK: - Subviews

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.clipsToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.07
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v
    }()

    private let tripImageView: RemoteImageView = {
        let iv = RemoteImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.systemGray5
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return iv
    }()

    private let destinationBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        v.layer.cornerRadius = 6
        return v
    }()

    private let destinationLabel: UILabel = UILabel.make(
        font: .systemFont(ofSize: 12, weight: .semibold),
        color: .white
    )

    private let titleLabel: UILabel = UILabel.make(
        font: .systemFont(ofSize: 16, weight: .bold)
    )

    private let dateLabel: UILabel = UILabel.make(
        font: .systemFont(ofSize: 13),
        color: .secondaryLabel
    )

    private let durationLabel: UILabel = UILabel.make(
        font: .systemFont(ofSize: 13),
        color: .secondaryLabel,
        alignment: .right
    )

    private let viewButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("View", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .brand
        b.layer.cornerRadius = 8
        return b
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.anchor(top: contentView.topAnchor, topPad: 0,
                             leading: contentView.leadingAnchor,
                             leadPad: 20,
                             trailing: contentView.trailingAnchor,
                             trailPad: 20,
                             bottom: contentView.bottomAnchor, botPad: 20)

        // Image
        containerView.addSubview(tripImageView)
        tripImageView.anchor(top: containerView.topAnchor,
                             leading: containerView.leadingAnchor,
                             trailing: containerView.trailingAnchor,
                             height: 180)

        // Destination badge over image
        destinationBadge.addSubview(destinationLabel)
        destinationLabel.anchor(top: destinationBadge.topAnchor, topPad: 5,
                                leading: destinationBadge.leadingAnchor, leadPad: 10,
                                trailing: destinationBadge.trailingAnchor, trailPad: 10,
                                bottom: destinationBadge.bottomAnchor, botPad: 5)
        tripImageView.addSubview(destinationBadge)
        destinationBadge.anchor(top: tripImageView.topAnchor, topPad: 10, trailing: tripImageView.trailingAnchor, trailPad: 10)

        // Title
        containerView.addSubview(titleLabel)
        titleLabel.anchor(top: tripImageView.bottomAnchor, topPad: 12,
                          leading: containerView.leadingAnchor, leadPad: 14,
                          trailing: containerView.trailingAnchor, trailPad: 14)

        // Date + Duration row
        containerView.addSubviews(dateLabel, durationLabel)
        dateLabel.anchor(top: titleLabel.bottomAnchor, topPad: 6,
                         leading: containerView.leadingAnchor, leadPad: 14)
        durationLabel.anchor(top: titleLabel.bottomAnchor, topPad: 6,
                             trailing: containerView.trailingAnchor, trailPad: 14)
        durationLabel.setContentHuggingPriority(.required, for: .horizontal)

        // View button
        containerView.addSubview(viewButton)
        viewButton.anchor(top: dateLabel.bottomAnchor, topPad: 14,
                          leading: containerView.leadingAnchor, leadPad: 14,
                          trailing: containerView.trailingAnchor, trailPad: 14,
                          bottom: containerView.bottomAnchor, botPad: 14,
                          height: 44)
    }

    // MARK: - Configure

    func configure(with trip: Trip) {
        tripImageView.load(urlString: trip.imageURL)
        destinationLabel.text = trip.destination
        titleLabel.text = trip.title
        dateLabel.text = trip.formattedStartDate
        durationLabel.text = "\(trip.durationDays) Days"
    }

    // MARK: - Press animation

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.containerView.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
        }
    }
}

// MARK: - Skeleton Cell

final class TripSkeletonCell: UITableViewCell {
    static let reuseID = "TripSkeletonCell"

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let imageBlock: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        return v
    }()

    private let titleBlock: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        v.layer.cornerRadius = 4
        return v
    }()

    private let dateBlock: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        v.layer.cornerRadius = 4
        return v
    }()

    private let buttonBlock: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        v.layer.cornerRadius = 8
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, leadPad: 20, trailing: contentView.trailingAnchor, trailPad: 20, bottom: contentView.bottomAnchor, botPad: 20)

        containerView.addSubviews(imageBlock, titleBlock, dateBlock, buttonBlock)
        imageBlock.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, height: 180)
        titleBlock.anchor(top: imageBlock.bottomAnchor, topPad: 12, leading: containerView.leadingAnchor, leadPad: 14, width: 160, height: 16)
        dateBlock.anchor(top: titleBlock.bottomAnchor, topPad: 8, leading: containerView.leadingAnchor, leadPad: 14, width: 110, height: 13)
        buttonBlock.anchor(top: dateBlock.bottomAnchor, topPad: 14, leading: containerView.leadingAnchor, leadPad: 14, trailing: containerView.trailingAnchor, trailPad: 14, bottom: containerView.bottomAnchor, botPad: 14, height: 44)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        [imageBlock, titleBlock, dateBlock, buttonBlock].forEach {
            $0.stopShimmering()
            $0.startShimmering()
        }
    }
}
