//
//  CryptoCurrencyWalletApp.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.10.2026.
//

import SwiftUI
import SwiftData

@main
struct CryptoWalletApp: App {
    // Проверяем при старте, есть ли сохраненный токен в Keychain
    @State private var isAuthenticated: Bool = KeychainManager.shared.read(
        service: "com.cryptowallet.auth",
        account: "user_auth_token"
    ) != nil
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    // Передаем логику выхода в ContentView
                    ContentView(onLogout: {
                        // 1. Удаляем токен из безопасного хранилища
                        KeychainManager.shared.delete(
                            service: "com.cryptowallet.auth",
                            account: "user_auth_token"
                        )
                        
                        // 2. Плавно возвращаем пользователя на UIKit-экран входа
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isAuthenticated = false
                        }
                    })
                    .transition(.move(edge: .trailing))
                } else {
                    // Токена нет — показываем ваш UIKit экран входа
                    LoginViewRepresentable {// trailing clouser - вызывет onSucces
                        // Этот блок сработает после успешного сохранения токена в Keychain
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isAuthenticated = true
                        }
                    }
                    .ignoresSafeArea(.keyboard) // Отключаем двойной сдвиг клавиатуры от SwiftUI, так как UIKit сам ей управляет!
                }
            }
        }
        .modelContainer(for: SDCoin.self)
    }
}
