import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {

    // MARK: - Layout Constants
    private enum Layout {
        static let iconTopSpacing: CGFloat = 60
        static let iconSize: CGFloat = 72
        static let titleTopSpacing: CGFloat = 20
        static let horizontalPadding: CGFloat = 24
        static let subtitleTopSpacing: CGFloat = 8
        static let fieldGroupTopSpacing: CGFloat = 40
        static let fieldHeight: CGFloat = 54
        static let errorLabelTopSpacing: CGFloat = 4
        static let errorLabelLeadingInset: CGFloat = 4
        static let fieldSpacing: CGFloat = 12
        static let buttonTopSpacing: CGFloat = 32
        static let bottomSpacing: CGFloat = 40
        static let fieldCornerRadius: CGFloat = 12
        static let fieldLeftPadding: CGFloat = 16
        static let titleFontSize: CGFloat = 28
        static let bodyFontSize: CGFloat = 16
        static let captionFontSize: CGFloat = 12
        static let transitionDuration: TimeInterval = 0.3
    }

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = LoginViewModel()

    // MARK: - UI
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "square.stack.3d.up.fill")
        iv.tintColor = .appPrimary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = Strings.Login.title
        l.font = .systemFont(ofSize: Layout.titleFontSize, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = Strings.Login.subtitle
        l.font = .systemFont(ofSize: Layout.bodyFontSize, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = Strings.Login.emailPlaceholder
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        tf.backgroundColor = .appCardBackground
        tf.layer.cornerRadius = Layout.fieldCornerRadius
        tf.layer.masksToBounds = true
        tf.setLeftPadding(Layout.fieldLeftPadding)
        tf.font = .systemFont(ofSize: Layout.bodyFontSize)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let emailErrorLabel: UILabel = {
        let l = UILabel()
        l.text = Strings.Login.emailError
        l.font = .systemFont(ofSize: Layout.captionFontSize)
        l.textColor = .systemRed
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = Strings.Login.passwordPlaceholder
        tf.isSecureTextEntry = true
        tf.borderStyle = .none
        tf.backgroundColor = .appCardBackground
        tf.layer.cornerRadius = Layout.fieldCornerRadius
        tf.layer.masksToBounds = true
        tf.setLeftPadding(Layout.fieldLeftPadding)
        tf.font = .systemFont(ofSize: Layout.bodyFontSize)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let passwordErrorLabel: UILabel = {
        let l = UILabel()
        l.text = Strings.Login.passwordError
        l.font = .systemFont(ofSize: Layout.captionFontSize)
        l.textColor = .systemRed
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let submitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = Strings.Login.signIn
        config.cornerStyle = .large
        config.baseBackgroundColor = .appPrimary
        config.baseForegroundColor = .white
        config.buttonSize = .large
        let btn = UIButton(configuration: config)
        btn.isEnabled = false
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appSurface
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        bindViewModel()
        setupKeyboardDismiss()
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubviews(
            iconImageView, titleLabel, subtitleLabel,
            emailField, emailErrorLabel,
            passwordField, passwordErrorLabel,
            submitButton
        )

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.iconTopSpacing),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: Layout.titleTopSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalPadding),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.subtitleTopSpacing),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Layout.fieldGroupTopSpacing),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalPadding),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalPadding),
            emailField.heightAnchor.constraint(equalToConstant: Layout.fieldHeight),

            emailErrorLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Layout.errorLabelTopSpacing),
            emailErrorLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor, constant: Layout.errorLabelLeadingInset),

            passwordField.topAnchor.constraint(equalTo: emailErrorLabel.bottomAnchor, constant: Layout.fieldSpacing),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: Layout.fieldHeight),

            passwordErrorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Layout.errorLabelTopSpacing),
            passwordErrorLabel.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor, constant: Layout.errorLabelLeadingInset),

            submitButton.topAnchor.constraint(equalTo: passwordErrorLabel.bottomAnchor, constant: Layout.buttonTopSpacing),
            submitButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: Layout.fieldHeight),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.bottomSpacing)
        ])
    }

    // MARK: - Binding
    private func bindViewModel() {
        let emailText = emailField.rx.text.orEmpty.asObservable()
        let passwordText = passwordField.rx.text.orEmpty.asObservable()

        let output = viewModel.transform(input: LoginViewModel.Input(
            email: emailText,
            password: passwordText,
            submitTap: submitButton.rx.tap.asObservable()
        ))

        output.isSubmitEnabled
            .drive(submitButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.isSubmitEnabled
            .map { $0 ? 1.0 : 0.5 }
            .drive(submitButton.rx.alpha)
            .disposed(by: disposeBag)

        // Show inline errors only after the user has started typing (skip initial value)
        output.isEmailValid
            .asObservable()
            .skip(1)
            .asDriver(onErrorJustReturn: true)
            .drive(emailErrorLabel.rx.isHidden)
            .disposed(by: disposeBag)

        output.isPasswordValid
            .asObservable()
            .skip(1)
            .asDriver(onErrorJustReturn: true)
            .drive(passwordErrorLabel.rx.isHidden)
            .disposed(by: disposeBag)

        output.loginSuccess
            .emit(onNext: { [weak self] in self?.navigateToMain() })
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation
    private func navigateToMain() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        window.rootViewController = MainTabBarController()
        UIView.transition(with: window, duration: Layout.transitionDuration, options: .transitionCrossDissolve, animations: nil)
    }

    // MARK: - Keyboard
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }
}
