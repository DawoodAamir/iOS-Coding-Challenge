import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {

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
        l.text = "Welcome Back"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Sign in to continue"
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email address"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        tf.backgroundColor = .appCardBackground
        tf.layer.cornerRadius = 12
        tf.layer.masksToBounds = true
        tf.setLeftPadding(16)
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let emailErrorLabel: UILabel = {
        let l = UILabel()
        l.text = "Enter a valid email address"
        l.font = .systemFont(ofSize: 12)
        l.textColor = .systemRed
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password (8–15 characters)"
        tf.isSecureTextEntry = true
        tf.borderStyle = .none
        tf.backgroundColor = .appCardBackground
        tf.layer.cornerRadius = 12
        tf.layer.masksToBounds = true
        tf.setLeftPadding(16)
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let passwordErrorLabel: UILabel = {
        let l = UILabel()
        l.text = "Password must be 8–15 characters"
        l.font = .systemFont(ofSize: 12)
        l.textColor = .systemRed
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let submitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign In"
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

            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 72),
            iconImageView.heightAnchor.constraint(equalToConstant: 72),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 54),

            emailErrorLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 4),
            emailErrorLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor, constant: 4),

            passwordField.topAnchor.constraint(equalTo: emailErrorLabel.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 54),

            passwordErrorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 4),
            passwordErrorLabel.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor, constant: 4),

            submitButton.topAnchor.constraint(equalTo: passwordErrorLabel.bottomAnchor, constant: 32),
            submitButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 54),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
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

        // Show inline errors only after first edit
        emailText.skip(1)
            .map { email -> Bool in
                guard !email.isEmpty else { return true }
                let regex = "[A-Z0-9a-z._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}"
                return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
            }
            .bind(to: emailErrorLabel.rx.isHidden)
            .disposed(by: disposeBag)

        passwordText.skip(1)
            .map { pw -> Bool in
                guard !pw.isEmpty else { return true }
                return (8...15).contains(pw.count)
            }
            .bind(to: passwordErrorLabel.rx.isHidden)
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
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

    // MARK: - Keyboard
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }
}
