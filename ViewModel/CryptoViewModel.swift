//
//  CryptoViewModel2.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 16.10.2026.
//

import Foundation
import CoreData

@Observable
@MainActor
class CryptoViewModel {
    var coins: [Coin] = []
    private var network = CryptoManager()
    private let coreDataManager = CoreDataManager.shared
    
    func fetchLocalCoins(){
        let context = coreDataManager.viewContext
        let request: NSFetchRequest<CDCoin> = CDCoin.fetchRequest()
        do {
            let localCDCoins = try context.fetch(request)
            self.coins = localCDCoins.map{ $0.coinsFromCoreDataToSwiftUIModel }

            print("Из кордата извлечено монет: \(self.coins.count)")
        } catch {
            print("Ошибка выборки CoreData: \(error)")
        }
    }
    
    func loadCryptoData() async {
        fetchLocalCoins()
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
        let context = coreDataManager.viewContext
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDCoin")
        let deleteOrder = NSBatchDeleteRequest(fetchRequest: deleteRequest)
        _ = try? context.execute(deleteOrder)
        
        for coin in loadedCoins {
            let newCDCoin = CDCoin(context: context)
            newCDCoin.id = coin.id
            newCDCoin.name = coin.name
            newCDCoin.price = coin.price
            newCDCoin.descriptionText = coin.description
            newCDCoin.priceChange24h = coin.priceChange24h
        }
        coreDataManager.saveContext()
        self.coins = loadedCoins
    }
    
}
