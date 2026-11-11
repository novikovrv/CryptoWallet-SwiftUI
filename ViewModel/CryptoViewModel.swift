//
//  CryptoViewModel2.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 16.10.2026.
//

import Foundation


@Observable
@MainActor
class CryptoViewModel {
    var coins: [Coin] = []
    private let network: CryptoNetworkServiceProtocol
    private var repository: CryptoStorageServiceProtocol?
    private let coinNames = ["BTC", "ETH", "NEAR", "SOUL"]
    
    // пишем опициональный инициализатор так как view model model создается раньше,
    // чем контекст @Environment(\.modelContext) загружается в View
    init(network: CryptoNetworkServiceProtocol = CryptoManager(), repository: CryptoStorageServiceProtocol? = nil){
        self.network = network
        self.repository = repository
    }
    func updateRepository(with repository: CryptoStorageServiceProtocol) {
        self.repository = repository
    }
    
    func fetchLocalCoins() {
        guard let repository = repository else {
            print("⚠️ ViewModel: Репозиторий не инициализирован (отсутствует ModelContext)")
            return
        }
        self.coins = repository.fetchLocalCoins()
        print("📦 ViewModel: Данные UI обновлены из SwiftData (\(self.coins.count) шт.)")
    }
    
    func loadCryptoData() async {
        guard let repository = repository else { return }
        
        print("🌐 ViewModel: Запуск фонового обновления данных...")
        
        // Шаг A: Идем в сеть за сырыми данными (CryptoManager ничего не знает о Coin)
        let rawDTOs = await network.fetchAllCrypto(names: coinNames)
        
        guard !rawDTOs.isEmpty else {
            print("⚠️ ViewModel: Сеть вернула пустой список, кэш не перезаписывается")
            return
        }
        
        // Шаг B: Превращаем сырые DTO в готовые UI-структуры Coin (Маппинг)
        let freshCoins = rawDTOs.map { dto in
            // Важная оптимизация: ищем, была ли эта монета на экране раньше.
            // Если была — сохраняем её UUID, чтобы у SwiftUI не ломались анимации.
            let existingId = self.coins.first(where: { $0.name == dto.name })?.id
            
            return Coin(
                   id: existingId ?? UUID(),
                   name: dto.name,
                   price: dto.price,
                   description: dto.description,
                   priceChange24h: dto.change
               )
        }
        // Шаг C: Отдаем новые монеты репозиторию на сохранение в SwiftData
        repository.saveCoins(freshCoins)
        
        // Шаг D: Перечитываем базу данных, чтобы синхронизировать UI-состояние
        fetchLocalCoins()
    }
}
