//
//  CryptoManager.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 12.10.2026.
//
import Foundation


nonisolated final class CryptoManager: CryptoNetworkServiceProtocol {
    
    func fetchCrypto(for coin: String) async throws -> (Double, String, Double){
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        switch coin {
        case "BTC": return (Double.random(in: 64000...98000),"Description BTC", Double.random(in:-100...100))
        case "ETH": return (Double.random(in: 3000...9000),"Description ETH", Double.random(in:-100...100))
        case "SOUL": return (Double.random(in: 11...1333),"Description SOUL", Double.random(in:-100...100))
        default: return (Double.random(in: 1...10),"Description Default", Double.random(in:-100...100))
        }
    }
    
    func fetchAllCrypto(names: [String]) async -> [CryptoDTO] {
        await withTaskGroup(of: CryptoDTO?.self) { group in
            for coinName in names {
                group.addTask {
                    do {
                        let (price, description, changing) = try await self.fetchCrypto(for: coinName)
                        // Сеть возвращает чистый объект данных, без UUID и логики UI
                        return CryptoDTO(name: coinName, price: price, description: description, change: changing)
                    } catch {
                        print("❌ Ошибка сети для \(coinName): \(error)")
                        return nil
                    }
                }
            }
            
            var dtos: [CryptoDTO] = []
            dtos.reserveCapacity(names.count)// оптимизация выделения памяти
            for await dto in group {
                if let dto = dto { dtos.append(dto) }
            }
            return dtos
        }
    }
}
