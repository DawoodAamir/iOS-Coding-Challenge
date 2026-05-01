import UIKit

extension UIColor {
    static let appPrimary = UIColor(red: 0.24, green: 0.46, blue: 0.96, alpha: 1)
    static let appSurface = UIColor.systemBackground
    static let appCardBackground = UIColor.secondarySystemBackground
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftViewMode = .always
    }
}
