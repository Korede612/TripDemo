//
//  Extensions.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 26/02/2026.
//

// MARK: - Helpers/Extensions.swift

import SwiftUI

// MARK: - Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - UIColor from Hex
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
    }

    static let brand = UIColor(hex: "#1A73E8")
    static let backgroundGray = UIColor(hex: "#F2F3F5")
    static let cardBackground = UIColor.white
    static let heroTop = UIColor(hex: "#E8F4F8")
    static let heroBottom = UIColor(hex: "#D0E8F0")
}

// MARK: - Corner Radius specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .white.opacity(0.4), location: 0.5),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .init(x: phase - 0.5, y: 0),
                    endPoint: .init(x: phase + 0.5, y: 0)
                )
                .blendMode(.screen)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

// MARK: - Auto Layout helpers
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    @discardableResult
    func anchor(
        top: NSLayoutYAxisAnchor? = nil, topPad: CGFloat = 0,
        leading: NSLayoutXAxisAnchor? = nil, leadPad: CGFloat = 0,
        trailing: NSLayoutXAxisAnchor? = nil, trailPad: CGFloat = 0,
        bottom: NSLayoutYAxisAnchor? = nil, botPad: CGFloat = 0,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        if let top      { constraints.append(topAnchor.constraint(equalTo: top, constant: topPad)) }
        if let leading  { constraints.append(leadingAnchor.constraint(equalTo: leading, constant: leadPad)) }
        if let trailing { constraints.append(trailingAnchor.constraint(equalTo: trailing, constant: -trailPad)) }
        if let bottom   { constraints.append(bottomAnchor.constraint(equalTo: bottom, constant: -botPad)) }
        if let width    { constraints.append(widthAnchor.constraint(equalToConstant: width)) }
        if let height   { constraints.append(heightAnchor.constraint(equalToConstant: height)) }
        NSLayoutConstraint.activate(constraints)
        return self
    }

    func fillSuperview(padding: UIEdgeInsets = .zero) {
        guard let sv = superview else { return }
        anchor(top: sv.topAnchor, topPad: padding.top,
               leading: sv.leadingAnchor, leadPad: padding.left,
               trailing: sv.trailingAnchor, trailPad: padding.right,
               bottom: sv.bottomAnchor, botPad: padding.bottom)
    }

    func centerInSuperview() {
        guard let sv = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: sv.centerXAnchor),
            centerYAnchor.constraint(equalTo: sv.centerYAnchor)
        ])
    }
}

// MARK: - UILabel factory
extension UILabel {
    static func make(
        text: String = "",
        font: UIFont,
        color: UIColor = .label,
        lines: Int = 1,
        alignment: NSTextAlignment = .left
    ) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = color
        l.numberOfLines = lines
        l.textAlignment = alignment
        return l
    }
}

// MARK: - Shimmer
extension UIView {
    func startShimmering() {
        let gradient = CAGradientLayer()
        gradient.name = "shimmer"
        gradient.frame = bounds
        gradient.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [0, 0.5, 1]
        layer.addSublayer(gradient)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue   = [1.0,  1.5,  2.0]
        animation.duration  = 1.2
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "shimmer")
    }

    func stopShimmering() {
        layer.sublayers?.removeAll(where: { $0.name == "shimmer" })
    }
}

// MARK: - Async Image loading
final class RemoteImageView: UIImageView {
    private var currentURL: URL?
    private static var cache = NSCache<NSURL, UIImage>()

    func load(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        currentURL = url

        if let cached = Self.cache.object(forKey: url as NSURL) {
            image = cached; return
        }

        backgroundColor = UIColor.systemGray5
        startShimmering()

        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let img = UIImage(data: data),
                  self.currentURL == url else { return }
            await MainActor.run {
                Self.cache.setObject(img, forKey: url as NSURL)
                self.stopShimmering()
                UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) {
                    self.image = img
                }
            }
        }
    }
}
