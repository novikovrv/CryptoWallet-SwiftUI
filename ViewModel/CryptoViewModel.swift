//
//  CryptoViewModel2.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 16.10.2026.
//

import Foundation
import SwiftData

@Observable
@MainActor
class CryptoViewModel {
    var coins: [Coin] = []
    private var network = CryptoManager()
    
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil){
        self.modelContext = modelContext
    }
    
    func updateContext(_ context: ModelContext){
        self.modelContext = context
    }
    
    func fetchLocalCoins() {
        guard let context = modelContext else { return }
        
        // Создаем простой дескриптор запроса (аналог NSFetchRequest)
        let descriptor = FetchDescriptor<SDCoin>()
        
        do {
            let localSDCoins = try context.fetch(descriptor)
            
            // Маппим SwiftData-модели в обычные структуры для UI
            self.coins = localSDCoins
                .map(Coin.init)
                .sorted{$0.name < $1.name}
            print("📦 Из SwiftData извлечено монет: \(self.coins.count)")
        } catch {
            print("❌ Ошибка выборки SwiftData: \(error)")
        }
    }
    
    func loadCryptoData() async {
        guard let context = modelContext else {return}
        let coinNames = ["BTC", "ETH", "SOUL"]
        var loadedCoins: [Coin] = []
        let networkManager = self.network
        await withTaskGroup(of: (String, Double, String, Double)?.self) { group in
            for coinName in coinNames {
                group.addTask {
                    do {
                        let (price, description, changing) = try await networkManager.fetchCrypto(for: coinName)
                        return (coinName, price, description, changing)
                    } catch {
                        print("Error to access coin \(coinName) \(error)")
                        return nil
                    }
                }
            }
            for await result in group {
                if let (name, price, description, changing) = result {
                    loadedCoins.append(Coin(id: UUID(), name: name, price: price, description: description, priceChange24h: changing))
                }
            }
        }
        do {
            try context.delete(model: SDCoin.self)
            
            
            for coin in loadedCoins {
                let newSDCoin =  SDCoin(from: coin)
                context.insert(newSDCoin) // Просто вставляем объект в контекст
            }
            try context.save()
            print("💾 SwiftData: Кэш успешно перезаписан на диск!")
            
        } catch {
            print("❌ Ошибка сохранения SwiftData: \(error)")
        }
        fetchLocalCoins()
    }
    
}
