//
//  ContentView.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.10.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // Получаем контекст SwiftData из окружения системы
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = CryptoViewModel()
    var body: some View {
        NavigationStack {
            List(viewModel.coins) {coin in
                NavigationLink(value: coin) {
                    HStack {
                        Text(coin.name)
                            .font(.headline)
                        Spacer()
                        Text(coin.price.formatted(.currency(code: "USD")))
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Крипто-Кошелек")
            .navigationDestination(for: Coin.self){ selectedCoin in
                CoinDetailView(coin:selectedCoin)
                
            }
            .task {
                let realRepository = CryptoRepository(context: modelContext)
                viewModel.updateRepository(with: realRepository)
                viewModel.fetchLocalCoins()
                await viewModel.loadCryptoData()
            }
            .refreshable {
                await viewModel.loadCryptoData()
            }
        }
    }
}

#Preview {
    
    //    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    //    let container = try! ModelContainer(for: SDCoin.self, configurations: config)
    //    let mockCoins = [
    //        SDCoin(name: "Bitcoin", price: 68500.0, descriptionText: "Digital Gold", priceChange24h: 1.5),
    //        SDCoin(name: "Ethereum", price: 2700.0, descriptionText: "Smart Contracts", priceChange24h: -0.8),
    //        SDCoin(name: "Solana", price: 165.0, descriptionText: "Fast Blockchain", priceChange24h: 4.2)
    //    ]
    //    for coin in mockCoins {
    //        container.mainContext.insert(coin)
    //    }
    //    return ContentView()
    //        .modelContainer(container)
}
