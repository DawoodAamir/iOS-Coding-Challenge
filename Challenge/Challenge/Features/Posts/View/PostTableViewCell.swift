import UIKit

final class PostTableViewCell: UITableViewCell {
    static let reuseID = "PostTableViewCell"

    // MARK: - Layout Constants
    private enum Layout {
        static let cardVerticalInset: CGFloat = 6
        static let cardHorizontalInset: CGFloat = 16
        static let contentPadding: CGFloat = 14
        static let contentSpacing: CGFloat = 6
        static let iconTrailingInset: CGFloat = 16
        static let iconSize: CGFloat = 22
        static let iconLeadingGap: CGFloat = 12
        static let cornerRadius: CGFloat = 14
        static let shadowOpacity: Float = 0.06
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let shadowRadius: CGFloat = 6
        static let titleFontSize: CGFloat = 15
        static let bodyFontSize: CGFloat = 13
    }

    // MARK: - UI
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .appCardBackground
        v.layer.cornerRadius = Layout.cornerRadius
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = Layout.shadowOpacity
        v.layer.shadowOffset = Layout.shadowOffset
        v.layer.shadowRadius = Layout.shadowRadius
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Layout.titleFontSize, weight: .semibold)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Layout.bodyFontSize, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let favoriteIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) { return nil }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        bodyLabel.text = nil
        favoriteIcon.image = nil
        favoriteIcon.tintColor = .systemGray3
    }

    // MARK: - Layout
    private func setupLayout() {
        contentView.addSubview(cardView)
        cardView.addSubviews(titleLabel, bodyLabel, favoriteIcon)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cardVerticalInset),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cardHorizontalInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.cardHorizontalInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cardVerticalInset),

            favoriteIcon.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            favoriteIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.iconTrailingInset),
            favoriteIcon.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            favoriteIcon.heightAnchor.constraint(equalToConstant: Layout.iconSize),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Layout.contentPadding),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.cardHorizontalInset),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteIcon.leadingAnchor, constant: -Layout.iconLeadingGap),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.contentSpacing),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Layout.contentPadding)
        ])
    }

    // MARK: - Configure
    func configure(with model: PostDisplayModel) {
        titleLabel.text = model.title
        bodyLabel.text = model.body
        favoriteIcon.image = UIImage(systemName: model.isFavorite ? "heart.fill" : "heart")
        favoriteIcon.tintColor = model.isFavorite ? .systemRed : .systemGray3
    }
}
