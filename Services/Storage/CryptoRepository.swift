//
//  CryptoRepository.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.11.2026.
//

import Foundation
import SwiftData

@MainActor
class CryptoRepository: CryptoStorageServiceProtocol {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchLocalCoins() -> [Coin] {
        let descriptor = FetchDescriptor<SDCoin>()
        do {
            let localSDCoins = try context.fetch(descriptor)
            
            return localSDCoins
                .map(Coin.init)
                .sorted {$0.name < $1.name}
        } catch {
            print("❌ Репозиторий: Ошибка выборки SwiftData: \(error)")
            return []
        }
    }
    
    func saveCoins(_ coins: [Coin]) {
        do {
            //try context.delete(model: SDCoin.self)
            for coin in coins {
                let newSDCoin = SDCoin(from: coin)
                context.insert(newSDCoin)
            }
            try context.save()
            print("💾 Репозиторий: Кэш успешно перезаписан на диск! (Монет: \(coins.count))")
        } catch {
            print("❌ Репозиторий: Ошибка сохранения SwiftData: \(error)")
        }
    }
}


