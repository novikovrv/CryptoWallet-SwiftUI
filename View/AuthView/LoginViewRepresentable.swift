//
//  LoginViewRepresentable.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 16.11.2026.
//

import SwiftUI
struct LoginViewRepresentable: UIViewControllerRepresentable {
    
    // Замыкание, которое сработает в SwiftUI, когда UIKit-контроллер сообщит об успешном входе
    var onSuccess: () -> Void
    
    // 1. Обязательный метод протокола: создает и настраивает ваш UIKit контроллер
    func makeUIViewController(context: Context) -> LoginViewController {//метод вызывает сама система
        let loginVC = LoginViewController()
        
        // Связываем событие из UIKit с действием в SwiftUI
        loginVC.onLoginSuccess = {//тоесть CryptoCurrencyWalletApp присваивает значение onSuccess в onLoginSuccess
            onSuccess()
        }
        
        return loginVC
    }
    
    // 2. Обязательный метод протокола: вызывается, если SwiftUI хочет обновить данные внутри UIKit
    // В нашем случае экран входа сам управляет своим состоянием, поэтому оставляем пустым
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
    }
}


