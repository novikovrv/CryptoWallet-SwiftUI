//
//  LoginViewController.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 13.11.2026.
//

import UIKit

final class LoginViewController: UIViewController {
    
    // Ссылка на ViewModel
    private let viewModel = LoginViewModel()
    
    // Замыкание, которое сообщит внешнему миру (SwiftUI), что вход выполнен успешно
    var onLoginSuccess: (() -> Void)?
    
    
    // MARK: - UI Elements (Создаем элементы через замыкания)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Вход в кошелек"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        // 🌟 КРИТИЧЕСКИ ВАЖНО ДЛЯ СОВРЕМЕННОГО UIKIT:
        // Отключаем старую систему масок (AutoresizingMask), чтобы заработал Auto Layout!
        // Если забыть эту строчку — экран сломается, а в консоль посыплются ошибки.
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите логин"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none // Отключаем авто-заглавную букву для логина
        textField.returnKeyType = .next          // На клавиатуре вместо "Ввод" будет кнопка "Далее"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите пароль"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true       // Скрываем символы точками
        textField.returnKeyType = .done          // Кнопка "Готово" на клавиатуре
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        // Используем современный конфигурационный стиль кнопок iOS 15+
        var config = UIButton.Configuration.filled()
        config.title = "Войти"
        config.baseBackgroundColor = .systemIndigo
        config.cornerStyle = .medium
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var buttonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Setup:
    private func setupConstraints() {
        // Создаем нижний констрейнт кнопки отдельно, чтобы управлять им при появлении клавиатуры.
        // Привязываемся к view.keyboardLayoutGuide (современный способ iOS 15+) или safeAreaLayoutGuide.
        let bottomConstraint = loginButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -30 // Отрицательный отступ, так как двигаемся вверх от нижнего края!
        )
        self.buttonBottomConstraint = bottomConstraint
        
        // Активируем все констрейнты единым массивом
        NSLayoutConstraint.activate([
            // 1. Кнопка "Войти" (верстаем снизу вверх)
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            bottomConstraint,
            
            // 2. Поле ввода пароля (привязываем над кнопкой)
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -24),
            
            // 3. Поле ввода логина (привязываем над полем пароля)
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginTextField.heightAnchor.constraint(equalToConstant: 44),
            loginTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -16),
            // 4. Заголовок экрана (привязываем над полем логина)
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            titleLabel.bottomAnchor.constraint(equalTo: loginTextField.topAnchor, constant: -32)
        ])
    }
    
    // MARK: - Lifecycle (Жизненный цикл контроллера)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegatesAndActions()
        setupKeyboardObservers()
        bindViewModel()
    }
    
    // 🌟 ВАЖНО ДЛЯ СОБЕСЕДОВАНИЙ: Очистка наблюдателей при уничтожении экрана
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("♻️ LoginViewController удален из памяти без утечек!")
    }
    // MARK: - Setup Logic & Actions
    
    private func setupDelegatesAndActions() {
        // 1. Назначаем контроллер делегатом обоих текстовых полей
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        // 2. Вешаем действие на нажатие кнопки (современный API UIAction)
        loginButton.addAction(UIAction { [weak self] _ in
            self?.handleLoginTap()
        }, for: .touchUpInside)
        
        // 3. Добавляем распознаватель тапа по фону для скрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    private func bindViewModel() {
        // Подписываемся на результат авторизации (обязательно [weak self], чтобы избежать Retain Cycle!)
        viewModel.onAuthResult = { [weak self] result in
            switch result {
            case .success:
                self?.onLoginSuccess?() // Сообщаем наверх об успехе
            case .failure(let error):
                self?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func handleLoginTap() {//Срабатывает при нажатии на вход
        dismissKeyboard()
        viewModel.login(login: loginTextField.text, password: passwordTextField.text)
    }
    
    @objc private func dismissKeyboard() {
        // Заставляет любое активное поле ввода (First Responder) закрыть клавиатуру
        view.endEditing(true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка входа", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Keyboard Handling (Фишка UIKit)
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // Достаем высоту клавиатуры из словаря системного уведомления
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        // Меняем константу нижнего констрейнта кнопки и плавно анимируем перерисовку экрана
        buttonBottomConstraint?.constant = -(keyboardHeight + 16)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded() // 🌟 Принудительно применяем новые констрейнты внутри блока анимации!
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        buttonBottomConstraint?.constant = -30
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    // MARK: - Setup
    
    private func setupUI() {
        // Обязательно задаем цвет фона! По умолчанию у пустого UIViewController он прозрачный (черный).
        view.backgroundColor = .systemBackground
        
        // В UIKit элементы не появятся на экране сами, их нужно вручную добавить в иерархию корневой view
        view.addSubview(titleLabel)
        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        setupConstraints()
    }
}

// MARK: - UITextFieldDelegate (Паттерн Делегирования)

extension LoginViewController: UITextFieldDelegate {
    // Вызывается при нажатии кнопки Return (Next / Done) на экранной клавиатуре
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            // Передаем фокус (First Responder) полю пароля
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            // Скрываем клавиатуру и запускаем вход
            handleLoginTap()
        }
        return true
    }
}

#Preview {
    LoginViewController()
}
