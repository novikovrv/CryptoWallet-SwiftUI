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
                while !Task.isCancelled {
                    await viewModel.loadCryptoData()
                    try? await Task.sleep(for: .seconds(30))
                }
            }
            .refreshable {
                await viewModel.loadCryptoData()
            }
        }
    }
}

#Preview {
    ContentView()
           // Создает временную базу SwiftData в оперативной памяти специально для холста
           .modelContainer(for: SDCoin.self, inMemory: true)
   
}
