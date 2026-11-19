//
//  LoginViewModel.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 16.11.2026.
//

import Foundation

final class LoginViewModel {
    
    // Внедряем зависимость через протокол (Dependency Injection)
    private let keychain: KeychainServiceProtocol
    
    // Константы для координат в Keychain
    private let serviceName = "com.cryptowallet.auth"
    private let accountName = "user_auth_token"
    
    // Замыкание (callback) для передачи результата обратно во ViewController
    var onAuthResult: ((Result<Void, Error>) -> Void)?
    
    init(keychain: KeychainServiceProtocol = KeychainManager.shared) {
        self.keychain = keychain
    }
    
    // Проверка, авторизован ли пользователь уже (есть ли токен в Keychain)
    func isUserLoggedIn() -> Bool {
        return keychain.read(service: serviceName, account: accountName) != nil
    }
    
    // Метод попытки входа
    func login(login: String?, password: String?) {
        // 1. Базовая валидация
        guard let login = login, !login.isEmpty,
              let password = password, password.count >= 4 else {
            let error = NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Введите логин и пароль (минимум 4 символа)"])
            onAuthResult?(.failure(error))
            return
        }
        
        // 2. Имитируем генерацию токена от сервера и сохраняем в безопасный Keychain
        let fakeServerToken = "jwt_token_\(login)_\(UUID().uuidString)"
        let isSaved = keychain.save(fakeServerToken, service: serviceName, account: accountName)
        
        if isSaved {
            print("🔐 Keychain: Токен успешно зашифрован и сохранен!")
            onAuthResult?(.success(()))
        } else {
            let error = NSError(domain: "Keychain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ошибка сохранения в Keychain"])
            onAuthResult?(.failure(error))
        }
    }
}
