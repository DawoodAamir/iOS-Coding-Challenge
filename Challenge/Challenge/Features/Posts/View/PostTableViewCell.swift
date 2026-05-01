import UIKit

final class PostTableViewCell: UITableViewCell {
    static let reuseID = "PostTableViewCell"

    // MARK: - UI
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .appCardBackground
        v.layer.cornerRadius = 14
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let favoriteIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemRed
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

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout
    private func setupLayout() {
        contentView.addSubview(cardView)
        cardView.addSubviews(titleLabel, bodyLabel, favoriteIcon)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            favoriteIcon.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            favoriteIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 22),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteIcon.leadingAnchor, constant: -12),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }

    // MARK: - Configure
    func configure(with post: PostObject) {
        titleLabel.text = post.title.prefix(1).uppercased() + post.title.dropFirst()
        bodyLabel.text = post.body
        let imageName = post.isFavorite ? "heart.fill" : "heart"
        favoriteIcon.image = UIImage(systemName: imageName)
        favoriteIcon.tintColor = post.isFavorite ? .systemRed : .systemGray3
    }
}
