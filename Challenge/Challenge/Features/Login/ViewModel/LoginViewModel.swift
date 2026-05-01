import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel {

    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let submitTap: Observable<Void>
    }

    struct Output {
        let isSubmitEnabled: Driver<Bool>
        let isEmailValid: Driver<Bool>
        let isPasswordValid: Driver<Bool>
        let loginSuccess: Signal<Void>
    }

    func transform(input: Input) -> Output {
        let isEmailValid = input.email
            .map { Self.isValidEmail($0) }
            .asDriver(onErrorJustReturn: false)

        let isPasswordValid = input.password
            .map { Self.isValidPassword($0) }
            .asDriver(onErrorJustReturn: false)

        let isSubmitEnabled = Driver
            .combineLatest(isEmailValid, isPasswordValid) { $0 && $1 }

        let loginSuccess = input.submitTap
            .do(onNext: { UserSessionManager.shared.login() })
            .asSignal(onErrorSignalWith: .empty())

        return Output(
            isSubmitEnabled: isSubmitEnabled,
            isEmailValid: isEmailValid,
            isPasswordValid: isPasswordValid,
            loginSuccess: loginSuccess
        )
    }

    private static func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private static func isValidPassword(_ password: String) -> Bool {
        return (8...15).contains(password.count)
    }
}
