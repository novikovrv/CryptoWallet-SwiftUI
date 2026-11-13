//
//  CoinDetailViewModel.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 12.11.2026.
//

import Foundation

@Observable
@MainActor
final class CoinDetailViewModel {
    var priceHistory: [PricePoint] = []
    var isLoading = false
    var errorMessage: String?
    
    let coin: Coin
    private let network: CryptoNetworkServiceProtocol
    
    // Внедряем конкретную монету и сетевой сервис через протокол (DI)
    init(coin: Coin, network: CryptoNetworkServiceProtocol = CryptoManager()) {
        self.coin = coin
        self.network = network
    }
    
    func loadWeeklyChart() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let points = try await network.fetchWeeklyChart(for: coin.name)
            self.priceHistory = points
        } catch {
            self.errorMessage = "Не удалось загрузить график цен"
            print("❌ Ошибка загрузки графика для \(coin.name): \(error)")
        }
        
        isLoading = false
    }
}
