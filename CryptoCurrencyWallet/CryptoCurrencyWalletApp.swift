//
//  CryptoCurrencyWalletApp.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.10.2026.
//

import SwiftUI
import SwiftData

@main
struct CryptoCurrencyWalletApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SDCoin.self)
    }
}
